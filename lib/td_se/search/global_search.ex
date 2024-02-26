defmodule TdSe.GlobalSearch do
  @moduledoc """
  Helper module to construct business concept search queries.
  """

  alias TdCore.Auth.Claims
  alias TdSe.Permissions
  alias TdSe.Search.Aggregations
  alias TdSe.Search.Query

  @search_permissions [
    "manage_confidential_business_concepts",
    "manage_confidential_structures",
    "view_data_structure",
    "view_published_business_concepts",
    "view_published_ingests"
  ]

  def search(params, claims, aliases, page \\ 0, size \\ 50)

  def search(params, %Claims{} = claims, aliases, page, size) do
    claims
    |> get_search_permissions()
    |> Query.build_query(aliases, Map.get(params, "query"))
    |> do_search(aliases, page, size)
  end

  defp get_search_permissions(claims) do
    Permissions.get_search_permissions(claims, @search_permissions)
  end

  defp do_search(%{match_none: _}, _aliases, _page, _size) do
    %{results: [], total: 0}
  end

  defp do_search(query, aliases, page, size) do
    search = %{
      from: page * size,
      size: size,
      query: query,
      aggs: Aggregations.aggregation_terms()
    }

    do_search(search, aliases)
  end

  defp do_search(search, %{} = aliases) do
    %{results: results, total: total} =
      aliases
      |> Map.keys()
      |> TdSe.Search.search(search)

    results =
      Enum.map(results, fn
        %{"_index" => index, "_source" => source} -> Map.put(source, "_index", index)
      end)

    %{results: results, total: total}
  end

  def alias_to_index_map(aliases, %Claims{role: "admin"}) do
    TdSe.Search.translate(aliases)
  end

  def alias_to_index_map(aliases, %Claims{} = claims) do
    permissions_to_aliases = Query.permissions_to_aliases()

    permitted_aliases =
      claims
      |> get_search_permissions()
      |> Enum.reject(fn {_, scope} -> scope == :none end)
      |> MapSet.new(fn {permission, _} -> Map.get(permissions_to_aliases, permission) end)
      |> Enum.filter(&Enum.member?(aliases, &1))

    TdSe.Search.translate(permitted_aliases)
  end
end
