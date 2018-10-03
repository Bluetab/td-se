defmodule TdSeWeb.SearchController do
  @moduledoc """
    Controller module for global search engine.
  """
  use TdSeWeb, :controller
  alias TdSe.GlobalSearch

  @all_indexes Application.get_env(:td_se, :elastic_indexes)

  def global_search(conn, params) do
    user = conn.assigns[:current_resource]
    params = add_indexes_to_params(params, Map.get(params, "indexes", nil))
    %{results: results, total: _total} = do_search(user, params, 0, 10_000)
    send_resp(conn, 200, results |> Poison.encode!)
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
        |> Map.keys()
        |> Enum.map(&Map.fetch!(&1, params))

    Map.put(params, "indexes", index_values)
  end
end
