defmodule TdSeWeb.ElasticIndexControllerTest do
  use ExUnit.Case
  use TdSeWeb.ConnCase

  import Mox

  setup %{conn: conn} do
    [conn: put_req_header(conn, "accept", "application/json")]
  end

  setup :verify_on_exit!

  describe "get /elastic_indexes" do
    @tag authentication: [role: "admin"]
    test "admin can list elastic indexes", %{conn: conn} do
      ElasticsearchMock
      |> Mox.expect(:request, 1, fn _, :get, "_alias", _, [] ->
        {:ok,
         %{
           "index_1" => %{"aliases" => %{"alias_1" => %{}}},
           "index_2" => %{"aliases" => %{"alias_2" => %{}}},
           "index_3" => %{"aliases" => %{}}
         }}
      end)
      |> Mox.expect(:request, 1, fn _, :get, "_stats/docs,store", _, [] ->
        {:ok,
         %{
           "indices" => %{
             "index_1" => %{
               "total" => %{
                 "store" => %{"size_in_bytes" => 123_456},
                 "docs" => %{"count" => 42}
               }
             },
             "index_2" => %{
               "total" => %{
                 "store" => %{"size_in_bytes" => 789_123},
                 "docs" => %{"count" => 24}
               }
             },
             "index_3" => %{
               "total" => %{
                 "store" => %{"size_in_bytes" => 42},
                 "docs" => %{"count" => 55}
               }
             }
           }
         }}
      end)

      assert %{
               "data" => [
                 %{
                   "alias" => "alias_1",
                   "documents" => 42,
                   "key" => "index_1",
                   "size" => 123_456
                 },
                 %{
                   "alias" => "alias_2",
                   "documents" => 24,
                   "key" => "index_2",
                   "size" => 789_123
                 },
                 %{"alias" => nil, "documents" => 55, "key" => "index_3", "size" => 42}
               ]
             } =
               conn
               |> get(~p"/api/elastic_indexes")
               |> json_response(:ok)
    end

    @tag authentication: [role: "user"]
    test "non-admin cannot list elastic indexes", %{conn: conn} do
      assert conn
             |> get(~p"/api/elastic_indexes")
             |> json_response(:forbidden)
    end
  end

  describe "delete /elastic_indexes/index_name" do
    @tag authentication: [role: "admin"]
    test "admin can delete an elastic index", %{conn: conn} do
      ElasticsearchMock
      |> expect(:request, fn _, :delete, "/rules-1696291200382459", _, _ ->
        {:ok,
         %{
           "rules-1699920000560187" => %{"aliases" => %{"rules" => %{}}},
           "structures-1705656711719278" => %{"aliases" => %{"structures" => %{}}}
         }}
      end)

      assert conn
             |> delete(~p"/api/elastic_indexes/rules-1696291200382459")
             |> response(:no_content)
    end

    @tag authentication: [role: "user"]
    test "non-admin cannot list elastic indexes", %{conn: conn} do
      assert conn
             |> delete(~p"/api/elastic_indexes/rules-1696291200382459")
             |> response(:forbidden)
    end
  end
end
