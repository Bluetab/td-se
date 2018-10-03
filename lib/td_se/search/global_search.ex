defmodule TdSe.GlobalSearch do
  @moduledoc """
    Helper module to construct business concept search queries.
  """
  alias TdSe.Accounts.User
  alias TdSe.BusinessConcept.Query
  alias TdSe.BusinessConcepts.BusinessConcept
  alias TdSe.Permissions
  alias TdSe.Search.Aggregations

  @search_service Application.get_env(:td_se, :elasticsearch)[:search_service]
  @data_structure_index Application.get_env(:td_se, :elastic_indexes)[:index_data_structure]
  @business_concept_index Application.get_env(:td_se, :elastic_indexes)[:index_bunsiness_concept]

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

    do_search(search)
  end

  # Non-admin user search, filters applied
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

    %{from: page * size, size: size, query: query, aggs: Aggregations.aggregation_terms()}
    |> do_search
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

  defp filter_by_index(@data_structure_index = index, permissions) do
    permissions
    |> Enum.filter(&Enum.member?(&1.permissions, :view_data_structure))
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp entry_to_filter_clause(
         %{resource_id: resource_id, permissions: permissions},
         @business_concept_index = index
       ) do
    domain_clause = %{term: %{domain_ids: resource_id}}
    index_clause = %{terms: %{_index: [index]}}

    status_clause =
      permissions
      |> Enum.map(&Map.get(BusinessConcept.permissions_to_status(), &1))
      |> Enum.filter(&(!is_nil(&1)))

    %{
      bool: %{filter: [domain_clause, index_clause, %{terms: %{status: status_clause}}]}
    }
  end

  defp entry_to_filter_clause(
         %{resource_id: resource_id, permissions: _},
         @data_structure_index = index
       ) do
    domain_clause = %{term: %{domain_ids: resource_id}}
    index_clause = %{terms: %{_index: [index]}}

    %{
      bool: %{filter: [domain_clause, index_clause]}
    }
  end

  defp do_search(search) do
    %{results: results, total: total} = @search_service.search(search)
    results = results |> Enum.map(
      fn result ->
        result |> Map.get("_source") |> Map.merge(Map.take(result, ["_index"]))
      end
      )
    %{results: results, total: total}
  end
end
