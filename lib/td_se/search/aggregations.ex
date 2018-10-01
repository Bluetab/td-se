defmodule TdSe.Search.Aggregations do
  @moduledoc """
    Aggregations for elasticsearch
  """

  def aggregation_terms do
    static_keywords = [
      {"_index", %{indices: %{terms: %{field: "_index"}}}}
    ]

    static_keywords
    |> Enum.into(%{})
  end
end
