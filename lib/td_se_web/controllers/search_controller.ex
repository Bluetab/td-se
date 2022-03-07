defmodule TdSeWeb.SearchController do
  @moduledoc """
  Controller module for global search engine.
  """
  use PhoenixSwagger
  use TdSeWeb, :controller
  alias TdSe.GlobalSearch
  alias TdSeWeb.SearchResultsView
  alias TdSeWeb.SwaggerDefinitions

  @aliases Application.compile_env(:td_se, :index_aliases)

  def swagger_definitions do
    SwaggerDefinitions.global_search_definitions()
  end

  swagger_path :global_search do
    post("/global_search")
    description("Search for all of our indexes under the whole search space")
    produces("application/json")

    parameters do
      search(:body, Schema.ref(:GlobalSearchRequest), "Search query and filter parameters")
    end

    response(200, "OK", Schema.ref(:GlobalSearchResponse))
  end

  def global_search(conn, params) do
    claims = conn.assigns[:current_resource]

    aliases =
      params
      |> Map.get("indexes", default_aliases())
      |> GlobalSearch.alias_to_index_map(claims)

    claims
    |> do_search(params, aliases, 0, 100)
    |> render_search_results(conn, aliases)
  end

  defp do_search(claims, params, aliases, page, size) do
    page = Map.get(params, "page", page)
    size = Map.get(params, "size", size)

    params
    |> Map.drop(["indexes", "page", "size"])
    |> GlobalSearch.search(claims, aliases, page, size)
  end

  defp default_aliases do
    Keyword.values(@aliases)
  end

  defp render_search_results(%{results: results, total: total}, conn, aliases) do
    global_search_results =
      Enum.reduce(aliases, [], fn {alias_name, index_name}, acc ->
        rs =
          results
          |> Enum.filter(&(&1["_index"] == index_name))
          |> Enum.map(&Map.put(&1, "_index", alias_name))

        result_map =
          %{}
          |> Map.put("index", alias_name)
          |> Map.put("results", rs)

        acc ++ [result_map]
      end)

    conn
    |> put_resp_header("x-total-count", "#{total}")
    |> put_view(SearchResultsView)
    |> render(
      "global_search_results.json",
      global_search_results: global_search_results
    )
  end
end
