defmodule TdSe.GlobalSearch do
  @moduledoc """
    Helper module to construct business concept search queries.
  """
  alias TdSe.Accounts.User
  alias TdSe.BusinessConcepts.BusinessConcept
  alias TdSe.Ingests.Ingest
  alias TdSe.Permissions
  alias TdSe.Search.Aggregations
  alias TdSe.Search.Query

  @search_service Application.get_env(:td_se, :elasticsearch)[:search_service]
  @data_structure_index Application.get_env(:td_se, :elastic_indexes)[:data_structure_index]
  @business_concept_index Application.get_env(:td_se, :elastic_indexes)[:business_concept_index]
  @ingest_index Application.get_env(:td_se, :elastic_indexes)[:ingest_index]

  def search(params, user, page \\ 0, size \\ 50)

  # Admin user search, no filters applied
  def search(params, %User{is_admin: true}, page, size) do
    query = create_query(params)

    search = %{
      from: page * size,
      size: size,
      query: query,
      aggs: Aggregations.aggregation_terms()
    }

    do_search(params, search)
  end

  def search(params, %User{} = user, page, size) do
    permissions = user |> Permissions.get_domain_permissions()
    filter(params, permissions, page, size)
  end

  def create_filters(%{"filters" => filters}) do
    filters
    |> Map.to_list()
    |> Enum.map(&to_terms_query/1)
  end

  def create_filters(_), do: []

  defp to_terms_query({filter, values}) do
    Aggregations.aggregation_terms()
    |> Map.get(filter)
    |> get_filter(values, filter)
  end

  defp get_filter(%{terms: %{field: field}}, values, _) do
    %{terms: %{field => values}}
  end

  defp filter(_params, [], _page, _size), do: []

  defp filter(params, [_h | _t] = permissions, page, size) do
    filter = permissions |> create_filter_clause(params)
    query = create_query(params, filter)

    search = %{
      from: page * size,
      size: size,
      query: query,
      aggs: Aggregations.aggregation_terms()
    }

    do_search(params, search)
  end

  defp create_query(%{"query" => query}) do
    equery = Query.add_query_wildcard(query)

    %{simple_query_string: %{query: equery}}
    |> bool_query
  end

  defp create_query(_params) do
    %{match_all: %{}}
    |> bool_query
  end

  defp create_query(%{"query" => query}, filter) do
    equery = Query.add_query_wildcard(query)

    %{simple_query_string: %{query: equery}}
    |> bool_query(filter)
  end

  defp create_query(_params, filter) do
    %{match_all: %{}}
    |> bool_query(filter)
  end

  defp bool_query(query, filter) do
    %{bool: %{must: query, filter: filter}}
  end

  defp bool_query(query) do
    %{bool: %{must: query}}
  end

  defp create_filter_clause(permissions, %{"indexes" => indexes}) do
    should_clause =
      indexes
      |> Enum.map(&filter_by_index(&1, permissions))
      |> Enum.flat_map(fn x -> x end)

    %{bool: %{should: should_clause}}
  end

  defp filter_by_index(@business_concept_index = index, permissions) do
    permissions
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp filter_by_index(@ingest_index = index, permissions) do
    permissions
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp filter_by_index(@data_structure_index = index, permissions) do
    permissions
    |> Enum.filter(&Enum.member?(&1.permissions, :view_data_structure))
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp entry_to_filter_clause(
         %{resource_id: resource_id, permissions: permissions},
         @business_concept_index = index
       ) do
    basic_clause = build_basic_clause(index, resource_id)

    confidential_clause =
      case Enum.member?(permissions, :manage_confidential_business_concepts) do
        true -> %{terms: %{"content._confidential.raw": ["Si", "No"]}}
        false -> %{terms: %{"content._confidential.raw": ["No"]}}
      end

    status =
      permissions
      |> Enum.map(&Map.get(BusinessConcept.permissions_to_status(), &1))
      |> Enum.filter(&(!is_nil(&1)))

    status_clause = %{terms: %{status: status}}

    %{
      bool: %{
        filter:
          basic_clause ++
            [
              confidential_clause,
              status_clause
            ]
      }
    }
  end

  defp entry_to_filter_clause(
         %{resource_id: resource_id, permissions: permissions},
         @data_structure_index = index
       ) do
    basic_clause = build_basic_clause(index, resource_id)

    confidential_clause =
      case Enum.member?(permissions, :manage_confidential_structures) do
        true -> %{terms: %{confidential: [true, false]}}
        false -> %{terms: %{confidential: [false]}}
      end

    %{
      bool: %{filter: basic_clause ++ [confidential_clause]}
    }
  end

  defp entry_to_filter_clause(
         %{resource_id: resource_id, permissions: permissions},
         @ingest_index = index
       ) do
    basic_clause = build_basic_clause(index, resource_id)

    status =
      permissions
      |> Enum.map(&Map.get(Ingest.permissions_to_status(), &1))
      |> Enum.filter(&(!is_nil(&1)))

    status_clause = %{terms: %{status: status}}

    %{
      bool: %{filter: basic_clause ++ [status_clause]}
    }
  end

  defp build_basic_clause(index, resource_id) do
    domain_clause = %{term: %{domain_ids: resource_id}}
    index_clause = %{terms: %{_index: [index]}}
    [domain_clause, index_clause]
  end

  defp do_search(%{"indexes" => indexes}, search) do
    %{results: results, total: total} = @search_service.search(indexes, search)

    results =
      results
      |> Enum.map(fn result ->
        result |> Map.get("_source") |> Map.merge(Map.take(result, ["_index"]))
      end)

    %{results: results, total: total}
  end
end
