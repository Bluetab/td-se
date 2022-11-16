defmodule SearchHelpers do
  @moduledoc """
  Helper functions for mocking search responses.
  """

  @indices ["concepts", "structures", "ingests"]

  def aliases_response do
    {:ok,
     %{
       "structures_test" => %{"aliases" => %{"structures_test_alias" => %{}}},
       "concepts_test" => %{"aliases" => %{"concepts_test_alias" => %{}}},
       "ingests_test" => %{"aliases" => %{"ingests_test_alias" => %{}}}
     }}
  end

  def hits_response(hits, total \\ nil) when is_list(hits) do
    hits = Enum.map(hits, &hit/1)

    total = total || Enum.count(hits)

    {:ok,
     %{
       "hits" => %{"hits" => hits, "total" => %{"relation" => "eq", "value" => total}},
       "aggregations" => aggs(hits, total)
     }}
  end

  defp hit(%{"id" => id, "_index" => index} = doc) do
    %{"id" => to_string(id), "_index" => index, "_source" => Map.delete(doc, "_index")}
  end

  defp hit(%{} = doc) do
    id = System.unique_integer([:positive])

    doc
    |> Map.put_new("id", id)
    |> Map.put_new("_index", Enum.random(@indices))
    |> hit()
  end

  defp aggs(hits, total) do
    buckets =
      hits
      |> Enum.frequencies_by(&Map.get(&1, "_index"))
      |> Enum.map(fn {key, doc_count} -> %{"key" => key, "doc_count" => doc_count} end)

    %{"_index" => %{"doc_count" => total}, "buckets" => buckets}
  end
end
