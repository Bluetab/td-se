defmodule TdSeWeb.SearchResultsView do
  use TdSeWeb, :view
  alias TdSeWeb.SearchResultsView

  def render("global_search_results.json", %{global_search_results: global_search_results}) do
    %{data: render_many(global_search_results, SearchResultsView, "search_results.json")}
  end

  def render("search_results.json", %{search_results: search_results}) do
    %{
      index: Map.get(search_results, "index"),
      results: render_many(Map.get(search_results, "results"), SearchResultsView, "search_result.json")
    }
  end

  def render("search_result.json", %{search_results: search_results}) do
    %{
      id: Map.get(search_results, "id"),
      name: Map.get(search_results, "name"),
      description: Map.get(search_results, "description"),
      index: Map.get(search_results, "_index")
    }
  end
end
