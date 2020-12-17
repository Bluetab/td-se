defmodule TdSe.Search.Aggregations do
  @moduledoc """
  Aggregations for elasticsearch
  """

  def aggregation_terms do
    static_keywords = [
      {"_index", %{terms: %{field: "_index"}}}
    ]

    static_keywords
    |> Enum.into(%{})
  end
end
