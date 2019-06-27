defmodule TdSe.Factory do
  @moduledoc """
  Factory builder for api entities
  """

  alias Jason, as: JSON

  def build_user(%{"sub" => sub, "jti" => jti}) do
    sub = sub |> JSON.decode!()

    %TdSe.Accounts.User{
      id: Map.get(sub, "id", 0),
      user_name: Map.get(sub, "user_name", "invented_user"),
      is_admin: Map.get(sub, "is_admin", false),
      jti: jti
    }
  end
end
