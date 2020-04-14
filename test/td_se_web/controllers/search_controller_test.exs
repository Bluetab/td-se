defmodule TdBgWeb.SearchControllerTest do
  @moduledoc false
  use ExUnit.Case, async: false
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"
  use TdSeWeb.ConnCase

  alias TdSe.Permissions.MockPermissionResolver
  alias TdSe.TestDataHelper

  @indices Application.get_env(:td_se, :indices)

  setup_all do
    start_supervised(MockPermissionResolver)
    :ok
  end

  setup %{conn: conn} do
    # Delete elastic content
    query = %{query: %{match_all: %{}}}
    TestDataHelper.clean_docs_from_indexes(@indices, query)
    TestDataHelper.bulk_test_data("static/bulk_content.json")
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "Search test" do
    @tag :admin_authenticated
    test "Search all indexes by default when admin is authenticated", %{
      conn: conn,
      swagger_schema: schema
    } do
      assert %{"data" => data} =
               conn
               |> post(Routes.search_path(conn, :global_search))
               |> validate_resp_schema(schema, "GlobalSearchResponse")
               |> json_response(:ok)

      assert length(data) == 3

      assert Enum.all?(data, fn %{"index" => index, "results" => results} ->
               case index do
                 "structures_test_alias" -> length(results) == 4
                 "concepts_test_alias" -> length(results) == 2
                 "ingests_test_alias" -> Enum.empty?(results)
               end
             end)
    end

    @tag :admin_authenticated
    test "Search all structures omitting deleted structures", %{
      conn: conn,
      swagger_schema: schema
    } do
      assert %{"data" => data} =
               conn
               |> post(Routes.search_path(conn, :global_search))
               |> validate_resp_schema(schema, "GlobalSearchResponse")
               |> json_response(:ok)

      assert length(data) == 3

      structure_results =
        data
        |> Enum.find(fn %{"index" => index} -> index == "structures_test_alias" end)
        |> Map.get("results")

      assert Enum.all?(structure_results, &is_nil(Map.get(&1, "deleted_at")))
    end

    @tag :admin_authenticated
    test "Search only queried indexes when admin is authenticated", %{
      conn: conn,
      swagger_schema: schema
    } do
      assert %{"data" => data} =
               conn
               |> post(
                 Routes.search_path(conn, :global_search),
                 indexes: [@indices[:data_structure_alias]]
               )
               |> validate_resp_schema(schema, "GlobalSearchResponse")
               |> json_response(:ok)

      assert [%{"results" => results}] = data
      assert length(results) == 4
    end
  end
end
