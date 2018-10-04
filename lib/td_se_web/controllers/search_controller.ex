defmodule TdSeWeb.SearchController do
  @moduledoc """
    Controller module for global search engine.
  """
  use PhoenixSwagger
  use TdSeWeb, :controller
  alias TdSe.GlobalSearch
  alias TdSeWeb.SearchResultsView
  alias TdSeWeb.SwaggerDefinitions

  @all_indexes Application.get_env(:td_se, :elastic_indexes)

  def swagger_definitions do
    SwaggerDefinitions.global_search_definitions()
  end

  swagger_path :global_search do
    post("/global_search")
    description("Search for all of our indexes under the whole search space")
    produces("application/json")
    parameters do
      search(
        :body,
        Schema.ref(:GlobalSearchRequest),
        "Search query and filter parameters"
      )
    end
    response(200, "OK", Schema.ref(:GlobalSearchResponse))
  end

  def global_search(conn, params) do
    user = conn.assigns[:current_resource]
    params = add_indexes_to_params(params, Map.get(params, "indexes", nil))
    user |> do_search(params, 0, 10_000) |> render_search_results(conn, params)
  end

  defp do_search(user, search_params, page, size) do
    page = search_params |> Map.get("page", page)
    size = search_params |> Map.get("size", size)

    search_params
    |> Map.drop(["page", "size"])
    |> GlobalSearch.search(user, page, size)
  end

  defp add_indexes_to_params(params, nil) do
    build_params(params)
  end

  defp add_indexes_to_params(params, []) do
    build_params(params)
  end

  defp add_indexes_to_params(params, _), do: params

  defp build_params(params) do
    index_values =
      @all_indexes
      |> Enum.map(fn {_k, v} -> v end)

    Map.put(params, "indexes", index_values)
  end

  defp render_search_results(%{results: results, total: total}, conn, %{"indexes" => indexes}) do
    global_search_results =
      indexes
      |> Enum.uniq()
      |> Enum.reduce([], fn index, acc ->
        result_map =
          %{}
            |> Map.put("index", index)
            |> Map.put("results", Enum.filter(results, &(&1["_index"] == index)))

        acc ++ [result_map]
      end)

    conn
    |> put_resp_header("x-total-count", "#{total}")
    |> render(
      SearchResultsView,
      "global_search_results.json",
      global_search_results: global_search_results
    )
  end
end
