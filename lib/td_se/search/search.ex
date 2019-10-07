defmodule TdSe.Search do
  @moduledoc """
  Search Engine calls
  """
  alias TdSe.ESClientApi

  def search(indexes, query) do
    response = ESClientApi.search_es(indexes, query)
    case response do
      {:ok, %HTTPoison.Response{body: %{"hits" => %{"hits" => results, "total" => total}}}} ->
        %{results: results, total: total}
      {:ok, %HTTPoison.Response{body: error}} ->
        error
    end
  end

  def translate(indexes) do
    response = ESClientApi.aliases()

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
          body
          |> Enum.map(fn {k, v} -> {k, v |> Map.get("aliases", %{}) |> Map.keys() |> Enum.at(0)} end)
          |> Enum.filter(fn {_k, v} -> v && v in indexes end)
          |> Enum.into(%{}, fn {k, v} -> {v, k} end)

      {:ok, error} ->
        Map.get(error, :body)
    end
  end
end
