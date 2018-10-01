defmodule TdSe.ESClientApi do
  use HTTPoison.Base
  require Logger
  alias Poison, as: JSON

  @moduledoc false

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
    Application.get_env(:td_se, :elasticsearch)[:type_name] # doc
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
