defmodule TdSe.Search.Aggregations do
  @moduledoc """
  Aggregations for elasticsearch
  """

  def aggregation_terms do
    %{"_index" => %{terms: %{field: "_index"}}}
  end
end
