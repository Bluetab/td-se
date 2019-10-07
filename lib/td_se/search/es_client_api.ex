defmodule TdSe.ESClientApi do
  use HTTPoison.Base

  alias Jason, as: JSON

  require Logger

  @moduledoc false

  def create_indexes do
    indexes_map =
      :code.priv_dir(:td_se)
      |> Path.join("static/indexes.json")
      |> File.read!()
      |> JSON.decode!()

    indexes_map
    |> Map.keys()
    |> Enum.map(fn index_name ->
      mapping = indexes_map |> Map.fetch!(index_name) |> JSON.encode!()
      %HTTPoison.Response{body: _response, status_code: status} = put!(index_name, mapping)
      Logger.info("Create index #{index_name} status #{status}")
    end)
  end

  def delete_indexes(options \\ []) do
    indexes_map =
      :code.priv_dir(:td_se)
      |> Path.join("static/indexes.json")
      |> File.read!()
      |> JSON.decode!()

    indexes_map
    |> Map.keys()
    |> Enum.map(fn index_name ->
      %HTTPoison.Response{body: _response, status_code: status} = delete!(index_name, options)
      Logger.info("Delete index #{index_name} status #{status}")
    end)
  end

  def bulk_index_content(items, refresh) do
    json_bulk_data =
      items
      |> Enum.map(fn item ->
        [build_bulk_metadata(item), build_bulk_doc(item)]
      end)
      |> List.flatten()
      |> Enum.join("\n")

    post("_bulk" <> "?refresh=#{refresh}", json_bulk_data <> "\n")
  end

  def delete_all_docs_by_query(index_name, query) do
    post("#{index_name}/" <> "_delete_by_query", query |> JSON.encode!())
  end

  defp build_bulk_doc(item) do
    "#{item |> Map.fetch!("search_fields") |> JSON.encode!()}"
  end

  defp build_bulk_metadata(item) do
    ~s({"index": {"_id": #{Map.fetch!(item, "id")}, "_type": "#{get_type_name()}", "_index": "#{
      Map.fetch!(item, "index_name")
    }"}})
  end

  def search_es(indexes, query) when is_list(indexes) do
    post("#{Enum.join(indexes, ",")}/" <> "_search/", query |> JSON.encode!())
  end

  def search_es(index_name, query) do
    post("#{index_name}/" <> "_search/", query |> JSON.encode!())
  end

  defp get_type_name do
    # doc
    Application.get_env(:td_se, :elasticsearch)[:type_name]
  end

  @doc """
  Concatenates elasticsearch path at the beggining of HTTPoison requests
  """
  def process_url(path) do
    es_config = Application.get_env(:td_se, :elasticsearch)
    "#{es_config[:es_host]}:#{es_config[:es_port]}/" <> path
  end

  @doc """
  Decodes response body
  """
  def process_response_body(body) do
    body
    |> JSON.decode!()
  end

  @doc """
  Adds requests headers
  """
  def process_request_headers(_headers) do
    [{"Content-Type", "application/json"}]
  end

  def aliases do
    get("_aliases/")
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
      |> JSON.decode!()
      |> Map.get("aliases")
      |> Enum.map(&(Map.new() |> Map.put(action, &1)))

    Map.new()
    |> Map.put("actions", aliases)
    |> post_aliases()
  end

  defp post_aliases(request) do
    post("_aliases", request |> JSON.encode!())
  end
end
