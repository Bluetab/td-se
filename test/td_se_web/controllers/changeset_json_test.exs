defmodule TdSeWeb.ChangesetJSONTest do
  use ExUnit.Case

  alias TdSeWeb.ChangesetJSON

  describe "error/1" do
    test "renders changeset errors" do
      changeset =
        {%{}, %{name: :string}}
        |> Ecto.Changeset.cast(%{"name" => nil}, [:name])
        |> Ecto.Changeset.validate_required([:name])

      result = ChangesetJSON.error(%{changeset: changeset})

      assert %{errors: errors} = result
      assert is_map(errors)
      assert Map.has_key?(errors, :name)
    end

    test "formats error messages correctly" do
      changeset =
        {%{}, %{email: :string, age: :integer}}
        |> Ecto.Changeset.cast(%{"email" => "invalid", "age" => -1}, [:email, :age])
        |> Ecto.Changeset.validate_format(:email, ~r/@/)
        |> Ecto.Changeset.validate_number(:age, greater_than: 0)

      result = ChangesetJSON.error(%{changeset: changeset})

      assert %{errors: errors} = result
      assert is_map(errors)
    end
  end
end
