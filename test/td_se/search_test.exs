defmodule TdSe.SearchTest do
  use ExUnit.Case

  import Mox

  alias TdSe.Search

  setup :verify_on_exit!

  describe "translate/1" do
    test "returns a map of aliases to indices" do
      ElasticsearchMock
      |> expect(:request, fn _, :get, "/_aliases", "", [] ->
        SearchHelpers.aliases_response()
      end)

      aliases = ["structures_test_alias", "concepts_test_alias", "foo"]

      assert Search.translate(aliases) == %{
               "concepts_test_alias" => "concepts_test",
               "structures_test_alias" => "structures_test"
             }
    end
  end
end
