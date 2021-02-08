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

  def search(index, query) when is_binary(index) do
    case Elasticsearch.post(Cluster, "/#{index}/_search", query) do
      {:ok, %{"hits" => %{"hits" => results, "total" => total}}} ->
        %{results: results, total: total}

      {:error, %Elasticsearch.Exception{message: message} = error} ->
        Logger.warn("Error response from Elasticsearch: #{message}")
        error
    end
  end

  def translate(indexes) do
    case Elasticsearch.get(Cluster, "/_aliases") do
      {:ok, %{} = body} ->
        body
        |> Enum.map(fn {k, v} -> {k, v |> Map.get("aliases", %{}) |> Map.keys() |> Enum.at(0)} end)
        |> Enum.filter(fn {_k, v} -> v && v in indexes end)
        |> Enum.into(%{}, fn {k, v} -> {v, k} end)

      {:error, %Elasticsearch.Exception{message: message} = error} ->
        Logger.warn("Error response from Elasticsearch: #{message}")
        error
    end
  end
end
