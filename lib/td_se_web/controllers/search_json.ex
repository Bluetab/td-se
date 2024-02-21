defmodule TdSeWeb.SearchJSON do
  def index(%{search_results: search_results}) do
    data =
      Enum.map(
        search_results,
        &%{
          index: Map.get(&1, "index"),
          results: for(search_result <- Map.get(&1, "results"), do: data(search_result))
        }
      )

    %{data: data}
  end

  def data(search_result) do
    index = Map.get(search_result, "_index")

    search_result
    |> Map.take(["id", "name", "description", "path", "business_concept_id"])
    |> Map.put("index", index)
  end
end
