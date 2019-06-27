defmodule TdSe.TestDataHelper do
  @moduledoc """
  Data helper for tests on elasticsearch
  """

  alias Jason, as: JSON
  alias TdSe.ESClientApi

  def clean_docs_from_indexes(index_list, query) do
    index_list
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.map(&ESClientApi.delete_all_docs_by_query(&1, query))
  end

  def bulk_test_data(path) do
    bulk_list =
      :code.priv_dir(:td_se)
      |> Path.join(path)
      |> File.read!()
      |> JSON.decode!()
      |> Map.fetch!("bulk_list")

    ESClientApi.bulk_index_content(bulk_list, "wait_for")
  end
end
