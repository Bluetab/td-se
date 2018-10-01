defmodule TdSe.Search do
  @moduledoc """
  Search Engine calls
  """
  alias TdSe.ESClientApi

  def search(query) do
    response = ESClientApi.search_es(query)
    case response do
      {:ok, %HTTPoison.Response{body: %{"hits" => %{"hits" => results, "total" => total}}}} ->
        %{results: results, total: total}
      {:ok, %HTTPoison.Response{body: error}} ->
        error
    end
  end
end
