defmodule TdSeWeb.SearchController do
  @moduledoc """
  Controller module for global search engine.
  """
  use PhoenixSwagger
  use TdSeWeb, :controller
  alias TdSe.GlobalSearch
  alias TdSeWeb.SearchResultsView
  alias TdSeWeb.SwaggerDefinitions

  @indices Application.compile_env(:td_se, :indices)

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

    params =
      params
      |> with_indexes(Map.get(params, "indexes", nil))
      |> GlobalSearch.translate_indexes()

    user |> do_search(params, 0, 10_000) |> render_search_results(conn, params)
  end

  defp do_search(user, search_params, page, size) do
    page = search_params |> Map.get("page", page)
    size = search_params |> Map.get("size", size)

    search_params
    |> Map.drop(["page", "size"])
    |> GlobalSearch.search(user, page, size)
  end

  defp with_indexes(params, nil) do
    default_indexes(params)
  end

  defp with_indexes(params, []) do
    default_indexes(params)
  end

  defp with_indexes(params, _), do: params

  defp default_indexes(params) do
    indices = Enum.map(@indices, fn {_k, v} -> v end)
    Map.put(params, "indexes", indices)
  end

  defp render_search_results(%{results: results, total: total}, conn, %{"indexes" => indexes}) do
    global_search_results =
      Enum.reduce(indexes, [], fn {index, es_index}, acc ->
        rs =
          results
          |> Enum.filter(&(&1["_index"] == es_index))
          |> Enum.map(&Map.put(&1, "_index", index))

        result_map =
          %{}
          |> Map.put("index", index)
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
