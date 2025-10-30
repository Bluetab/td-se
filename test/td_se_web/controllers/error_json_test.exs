defmodule TdSeWeb.ErrorJSONTest do
  use ExUnit.Case

  alias TdSeWeb.ErrorJSON

  describe "render/2" do
    test "renders error with message" do
      result = ErrorJSON.render("500.json", %{message: "Internal Server Error"})

      assert result == %{error: "Internal Server Error"}
    end

    test "renders error without message uses template status" do
      result = ErrorJSON.render("404.json", %{})

      assert %{errors: %{detail: detail}} = result
      assert detail == "Not Found"
    end

    test "renders 500 error" do
      result = ErrorJSON.render("500.json", %{})

      assert %{errors: %{detail: detail}} = result
      assert detail == "Internal Server Error"
    end

    test "renders 400 error" do
      result = ErrorJSON.render("400.json", %{})

      assert %{errors: %{detail: detail}} = result
      assert detail == "Bad Request"
    end
  end
end
