defmodule TdSeWeb.FallbackControllerTest do
  use TdSeWeb.ConnCase

  alias TdSeWeb.FallbackController

  describe "call/2" do
    test "handles Ecto changeset errors", %{conn: conn} do
      conn = %{conn | params: %{"_format" => "json"}}

      changeset =
        {%{}, %{field: :string}}
        |> Ecto.Changeset.cast(%{"field" => nil}, [:field])
        |> Ecto.Changeset.validate_required([:field])

      {:error, changeset} = Ecto.Changeset.apply_action(changeset, :validate)
      result = FallbackController.call(conn, {:error, changeset})

      assert result.status == 422
      assert result.private.phoenix_view == %{"json" => TdSeWeb.ChangesetJSON}
    end

    test "handles unprocessable entity with message", %{conn: conn} do
      conn = %{conn | params: %{"_format" => "json"}}
      result = FallbackController.call(conn, {:error, :unprocessable_entity, "test message"})

      assert result.status == 422
      assert result.private.phoenix_view == %{"json" => TdSeWeb.ErrorJSON}
    end

    test "handles forbidden errors", %{conn: conn} do
      conn = %{conn | params: %{"_format" => "json"}}
      result = FallbackController.call(conn, {:error, :forbidden})

      assert result.status == 403
      assert result.private.phoenix_view == %{"json" => TdSeWeb.ErrorJSON}
    end

    test "handles not found errors", %{conn: conn} do
      conn = %{conn | params: %{"_format" => "json"}}
      result = FallbackController.call(conn, {:error, :not_found})

      assert result.status == 404
      assert result.private.phoenix_view["json"] == TdSeWeb.ErrorJSON
    end
  end
end
