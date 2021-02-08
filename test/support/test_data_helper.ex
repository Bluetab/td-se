defmodule TdSe.TestDataHelper do
  @moduledoc """
  Data helper for tests on elasticsearch
  """

  alias ElasticsearchSupport

  def clean_docs_from_indexes(index_list, query) do
    index_list
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.map(&ElasticsearchSupport.delete_all_docs_by_query(&1, query))
  end

  def bulk_test_data(path) do
    bulk_list =
      :code.priv_dir(:td_se)
      |> Path.join(path)
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("bulk_list")

    ElasticsearchSupport.bulk_index_content(bulk_list, "wait_for")
  end
end
