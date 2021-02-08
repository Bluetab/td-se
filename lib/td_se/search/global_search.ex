defmodule TdSe.GlobalSearch do
  @moduledoc """
  Helper module to construct business concept search queries.
  """

  alias TdSe.Auth.Claims
  alias TdSe.BusinessConcepts.BusinessConcept
  alias TdSe.Ingests.Ingest
  alias TdSe.Permissions
  alias TdSe.Search.Aggregations
  alias TdSe.Search.Query

  @data_structure_alias Application.compile_env(:td_se, :indices)[:data_structure_alias]
  @business_concept_alias Application.compile_env(:td_se, :indices)[:business_concept_alias]
  @ingest_alias Application.compile_env(:td_se, :indices)[:ingest_alias]

  @business_concept_permissions [
    :view_published_business_concepts,
    :manage_confidential_business_concepts
  ]
  @ingest_permissions [:view_published_ingests]
  @data_structure_permissions [:view_data_structure]

  def search(params, claims, page \\ 0, size \\ 50)

  def search(params, %Claims{role: "admin"}, page, size) do
    default_status_filter = create_default_filter_clause(params)
    query = create_query(params, default_status_filter)

    search = %{
      from: page * size,
      size: size,
      query: query,
      aggs: Aggregations.aggregation_terms()
    }

    do_search(params, search)
  end

  def search(params, %Claims{} = claims, page, size) do
    permissions = Permissions.get_domain_permissions(claims)
    filter(params, permissions, page, size)
  end

  def translate_indexes(%{"indexes" => indexes} = params) do
    Map.put(params, "indexes",  TdSe.Search.translate(indexes))
  end

  defp filter(_params, [], _page, _size), do: []

  defp filter(params, [_h | _t] = permissions, page, size) do
    filter = create_filter_clause(permissions, params)
    query = create_query(params, filter)

    search = %{
      from: page * size,
      size: size,
      query: query,
      aggs: Aggregations.aggregation_terms()
    }

    do_search(params, search)
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

  defp create_filter_clause(permissions, %{"indexes" => indexes}) do
    should_clause =
      indexes
      |> Enum.map(&filter_by_index(&1, permissions))
      |> Enum.flat_map(fn x -> x end)

    %{bool: %{should: should_clause}}
  end

  defp create_default_filter_clause(%{"indexes" => indexes}) do
    should_clause =
      indexes
      |> Enum.map(&default_filter_for_index(&1))

    %{bool: %{should: should_clause}}
  end

  defp filter_by_index({@business_concept_alias, _es_index} = index, permissions) do
    permissions
    |> Enum.filter(&filter_by_permission(&1, @business_concept_permissions))
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp filter_by_index({@ingest_alias, _es_index} = index, permissions) do
    permissions
    |> Enum.filter(&filter_by_permission(&1, @ingest_permissions))
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp filter_by_index({@data_structure_alias, _es_index} = index, permissions) do
    permissions
    |> Enum.filter(&filter_by_permission(&1, @data_structure_permissions))
    |> Enum.map(&entry_to_filter_clause(&1, index))
  end

  defp default_filter_for_index({@business_concept_alias, es_index}) do
    %{
      bool: %{
        filter: [
          %{terms: %{_index: [es_index]}},
          %{terms: %{status: BusinessConcept.default_status()}}
        ]
      }
    }
  end

  defp default_filter_for_index({@ingest_alias, es_index}) do
    %{
      bool: %{
        filter: [
          %{terms: %{_index: [es_index]}},
          %{terms: %{status: Ingest.default_status()}}
        ]
      }
    }
  end

  defp default_filter_for_index({@data_structure_alias, es_index}) do
    %{
      bool: %{
        filter: [
          %{terms: %{_index: [es_index]}},
          %{bool: %{must_not: %{exists: %{field: "deleted_at"}}}}
        ]
      }
    }
  end

  defp default_filter_for_index({_, es_index}) do
    %{
      bool: %{
        filter: [
          %{terms: %{_index: [es_index]}}
        ]
      }
    }
  end

  defp entry_to_filter_clause(
         %{resource_id: resource_id, permissions: permissions},
         {@business_concept_alias, es_index}
       ) do
    basic_clause = build_basic_clause(es_index, resource_id)

    confidential_clause =
      case Enum.member?(permissions, :manage_confidential_business_concepts) do
        true -> %{terms: %{"confidential.raw": [true, false]}}
        false -> %{terms: %{"confidential.raw": [false]}}
      end

    status =
      permissions
      |> Enum.filter(&Enum.member?(@business_concept_permissions, &1))
      |> Enum.map(&Map.get(BusinessConcept.permissions_to_status(), &1))
      |> Enum.filter(&(not is_nil(&1)))

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
         {@data_structure_alias, es_index}
       ) do
    basic_clause = build_basic_clause(es_index, resource_id)

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
         {@ingest_alias, es_index}
       ) do
    basic_clause = build_basic_clause(es_index, resource_id)

    status =
      permissions
      |> Enum.filter(&Enum.member?(@ingest_permissions, &1))
      |> Enum.map(&Map.get(Ingest.permissions_to_status(), &1))
      |> Enum.filter(&(not is_nil(&1)))

    status_clause = %{terms: %{status: status}}

    %{
      bool: %{filter: basic_clause ++ [status_clause]}
    }
  end

  defp filter_by_permission(%{permissions: permissions}, target_values) do
    target_values
    |> Enum.any?(&Enum.member?(permissions, &1))
  end

  defp filter_by_permission(_, _), do: false

  defp build_basic_clause(index, resource_id) do
    domain_clause = %{term: %{domain_ids: resource_id}}
    index_clause = %{terms: %{_index: [index]}}
    [domain_clause, index_clause]
  end

  defp do_search(%{"indexes" => indexes}, search) do
    %{results: results, total: total} =
      TdSe.Search.search(Enum.map(indexes, fn {k, _v} -> k end), search)

    results =
      results
      |> Enum.map(fn result ->
        result |> Map.get("_source") |> Map.merge(Map.take(result, ["_index"]))
      end)

    %{results: results, total: total}
  end
end
