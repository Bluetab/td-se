defmodule TdBgWeb.SearchControllerTest do
  @moduledoc false
  use ExUnit.Case, async: false
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"
  alias TdSe.Permissions.MockPermissionResolver
  alias TdSe.TestDataHelper
  use TdSeWeb.ConnCase

  setup_all do
    start_supervised(MockPermissionResolver)
    :ok
  end

  @all_indexes Application.get_env(:td_se, :elastic_indexes)

  setup %{conn: conn} do
    # Delete elastic content
    query = %{query: %{match_all: %{}}}
    TestDataHelper.clean_docs_from_indexes(@all_indexes, query)
    TestDataHelper.bulk_test_data("static/bulk_content.json")
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "Search test" do
    @tag :admin_authenticated
    test "Search all indexes by default when admin is authenticated", %{
      conn: conn,
      swagger_schema: schema
    } do
      conn =
        post(
          conn,
          Routes.search_path(conn, :global_search)
        )

      validate_resp_schema(conn, schema, "GlobalSearchResponse")
      result_data = json_response(conn, 200)["data"]
      assert length(result_data) == 3

      assert Enum.all?(result_data, fn %{"index" => index, "results" => results} ->
               case index do
                 "structures_test_alias" -> length(results) == 4
                 "concepts_test_alias" -> length(results) == 2
                 "ingests_test_alias" -> Enum.empty?(results)
               end
             end)
    end

    @tag :admin_authenticated
    test "Search only queried indexes when admin is authenticated", %{
      conn: conn,
      swagger_schema: schema
    } do
      conn =
        post(
          conn,
          Routes.search_path(conn, :global_search),
          indexes: [@all_indexes[:data_structure_alias]]
        )

      validate_resp_schema(conn, schema, "GlobalSearchResponse")
      result_data = json_response(conn, 200)["data"]
      assert length(result_data) == 1

      assert Enum.all?(result_data, fn index_result ->
               length(Map.get(index_result, "results")) == 4
             end)
    end
  end
end
