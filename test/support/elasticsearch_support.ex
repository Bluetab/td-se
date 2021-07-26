defmodule ElasticsearchSupport do
  @moduledoc false

  require Logger

  alias TdSe.Search.Cluster

  def create_indexes do
    index_mappings()
    |> Enum.map(fn {index_name, mapping} ->
      case Elasticsearch.put(Cluster, index_name, mapping) do
        {:error, %Elasticsearch.Exception{type: "resource_already_exists_exception"}} ->
          Logger.warn("Index #{index_name} exists")

        {:ok, _} ->
          Logger.info("Created index #{index_name}")
      end
    end)
  end

  def delete_indexes do
    index_mappings()
    |> Map.keys()
    |> Enum.each(&Elasticsearch.delete!(Cluster, &1))
  end

  defp index_mappings do
    :code.priv_dir(:td_se)
    |> Path.join("static/indices.json")
    |> File.read!()
    |> Jason.decode!()
  end

  def bulk_index_content(items, refresh) do
    json_bulk_data =
      items
      |> Enum.map(fn item ->
        [build_bulk_metadata(item), build_bulk_doc(item)]
      end)
      |> List.flatten()
      |> Enum.join("\n")

    Elasticsearch.post!(Cluster, "_bulk?refresh=#{refresh}", json_bulk_data <> "\n")
  end

  def delete_all_docs_by_query(index_name, query) do
    Elasticsearch.post!(Cluster, "#{index_name}/_delete_by_query", query)
  end

  defp build_bulk_doc(item) do
    item |> Map.fetch!("search_fields") |> Jason.encode!()
  end

  defp build_bulk_metadata(item) do
    ~s({"index": {"_id": #{Map.fetch!(item, "id")}, "_type": "doc", "_index": "#{Map.fetch!(item, "index_name")}"}})
  end

  def create_aliases do
    aliases_request("add")
  end

  def delete_aliases do
    aliases_request("remove")
  end

  def aliases_request(action) do
    aliases =
      :code.priv_dir(:td_se)
      |> Path.join("static/aliases.json")
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("aliases")
      |> Enum.map(&%{action => &1})

    Elasticsearch.post!(Cluster, "_aliases", %{actions: aliases})
  end
end
