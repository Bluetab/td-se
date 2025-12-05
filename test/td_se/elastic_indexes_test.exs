defmodule TdSe.ElasticIndexesTest do
  use ExUnit.Case

  import Mox

  alias TdSe.ElasticIndexes
  setup :verify_on_exit!

  describe "elastic_indexes" do
    test "list_elastic_indexes/0 returns all elastic_indexes" do
      indices_list = [
        %{
          alias: "implementations",
          documents: 95_283,
          key: "implementations-1707153260425924",
          size: 15_277_855
        },
        %{alias: "rules", documents: 254, key: "rules-1707154839278682", size: 285_352}
      ]

      ElasticsearchMock
      |> expect(:request, fn _, :get, "_alias", "", [] ->
        {:ok,
         %{
           "implementations-1707153260425924" => %{
             "aliases" => %{
               "implementations" => %{}
             }
           },
           "rules-1707154839278682" => %{
             "aliases" => %{
               "rules" => %{}
             }
           }
         }}
      end)

      ElasticsearchMock
      |> expect(:request, fn _, :get, "_stats/docs,store", "", [] ->
        {:ok,
         %{
           "indices" => %{
             "rules-1707154839278682" => %{
               "uuid" => "BxjtcMQJTLijqi2snej8JA",
               "primaries" => %{
                 "docs" => %{
                   "count" => 254,
                   "deleted" => 0
                 },
                 "store" => %{
                   "size_in_bytes" => 285_352,
                   "reserved_in_bytes" => 0
                 }
               },
               "total" => %{
                 "docs" => %{
                   "count" => 254,
                   "deleted" => 0
                 },
                 "store" => %{
                   "size_in_bytes" => 285_352,
                   "reserved_in_bytes" => 0
                 }
               }
             },
             "implementations-1707153260425924" => %{
               "uuid" => "4f7JHoAuTwWHW4HIgkpicg",
               "primaries" => %{
                 "docs" => %{
                   "count" => 95_283,
                   "deleted" => 0
                 },
                 "store" => %{
                   "size_in_bytes" => 15_277_855,
                   "reserved_in_bytes" => 0
                 }
               },
               "total" => %{
                 "docs" => %{
                   "count" => 95_283,
                   "deleted" => 0
                 },
                 "store" => %{
                   "size_in_bytes" => 15_277_855,
                   "reserved_in_bytes" => 0
                 }
               }
             }
           }
         }}
      end)

      assert ElasticIndexes.list_elastic_indexes() == indices_list
    end

    test "delete_elastic_index/1 deletes the elastic_index" do
      ElasticsearchMock
      |> expect(:request, fn _, :delete, "/rules-1696291200382459", _, _ ->
        {:ok,
         %{
           "rules-1699920000560187" => %{"aliases" => %{"rules" => %{}}},
           "structures-1705656711719278" => %{"aliases" => %{"structures" => %{}}}
         }}
      end)

      assert {:ok, %{}} = ElasticIndexes.delete_elastic_index("rules-1696291200382459")
    end
  end
end
