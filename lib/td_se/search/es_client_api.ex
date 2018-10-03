defmodule TdSe.ESClientApi do
  use HTTPoison.Base
  require Logger
  alias Poison, as: JSON

  @moduledoc false

  def create_indexes do
    indexes_map =
      :code.priv_dir(:td_se)
      |> Path.join("static/indexes.json")
      |> File.read!()
      |> Poison.decode!()

    indexes_map
    |> Map.keys()
    |> Enum.map(fn index_name ->
      mapping = indexes_map |> Map.fetch!(index_name) |> Poison.encode!()
      %HTTPoison.Response{body: _response, status_code: status} = put!(index_name, mapping)
      Logger.info("Create index #{index_name} status #{status}")
    end)
  end

  def delete_indexes(options \\ []) do
    indexes_map =
      :code.priv_dir(:td_se)
      |> Path.join("static/indexes.json")
      |> File.read!()
      |> Poison.decode!()

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

  defp build_bulk_doc(item) do
    "#{item |> Map.fetch!("search_fields") |> Poison.encode!()}"
  end

  defp build_bulk_metadata(item) do
    ~s({"index": {"_id": #{Map.fetch!(item, "id")}, "_type": "#{get_type_name()}", "_index": "#{
      Map.fetch!(item, "index_name")
    }"}})
  end

  @doc """
  Loads all index configuration into elasticsearch
  """
  def index_content(index_name, id, body) do
    put(get_search_path(index_name, id), body)
  end

  def delete_content(index_name, id) do
    delete(get_search_path(index_name, id))
  end

  def search_es(index_name, query) do
    post("#{index_name}/" <> "_search/", query |> JSON.encode!())
  end

  def search_es(query) do
    post("_search/", query |> JSON.encode!())
  end

  defp get_type_name do
    # doc
    Application.get_env(:td_se, :elasticsearch)[:type_name]
  end

  defp get_search_path(index_name, id) do
    type_name = get_type_name()
    "#{index_name}/" <> "#{type_name}/" <> "#{id}"
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
    |> Poison.decode!()
  end

  @doc """
    Adds requests headers
  """
  def process_request_headers(_headers) do
    headers = [{"Content-Type", "application/json"}]
    headers
  end
end
