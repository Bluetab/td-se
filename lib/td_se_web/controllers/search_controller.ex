defmodule TdSeWeb.SearchController do
  @moduledoc """
    Controller module for global search engine.
  """
  use TdSeWeb, :controller
  alias TdSe.GlobalSearch

  def global_search(conn, params) do
    user = conn.assigns[:current_user]
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
end
