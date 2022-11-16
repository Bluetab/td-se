defmodule TdSe.Search do
  @moduledoc """
  Search Engine calls
  """

  require Logger

  alias TdSe.Search.Cluster

  def search(indices, query) when is_list(indices) do
    indices
    |> Enum.join(",")
    |> search(query)
  end

  def search("", query) do
    do_search("/_search", query)
  end

  def search(index, query) when is_binary(index) do
    do_search("/#{index}/_search", query)
  end

  def do_search(url, query) do
    case Elasticsearch.post(Cluster, url, query, params: %{"track_total_hits" => "true"}) do
      {:ok, %{"hits" => %{"hits" => results, "total" => total}}} ->
        %{results: results, total: get_total(total)}

      {:error, %Elasticsearch.Exception{message: message} = error} ->
        Logger.warn("Error response from Elasticsearch: #{message}")
        error
    end
  end

  def translate(aliases) do
    case Elasticsearch.get(Cluster, "/_aliases") do
      {:ok, %{} = body} ->
        body
        |> Enum.reduce(%{}, &reduce_aliases/2)
        |> Map.take(aliases)

      {:error, %Elasticsearch.Exception{message: message} = error} ->
        Logger.warn("Error response from Elasticsearch: #{message}")
        error
    end
  end

  defp reduce_aliases({index, %{"aliases" => %{} = aliases}}, acc) when map_size(aliases) > 0 do
    aliases
    |> Map.keys()
    |> Enum.reduce(acc, &Map.put(&2, &1, index))
  end

  defp reduce_aliases(_, acc), do: acc

  defp get_total(value) when is_integer(value), do: value
  defp get_total(%{"relation" => "eq", "value" => value}) when is_integer(value), do: value
end
