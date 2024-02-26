defmodule TdSe.Permissions do
  @moduledoc """
  The Permissions context.
  """

  alias TdCore.Auth.Claims

  def get_search_permissions(%Claims{role: role}, permissions)
      when role in ["admin", "service"] and is_list(permissions) do
    Map.new(permissions, &{&1, :all})
  end

  def get_search_permissions(%Claims{} = claims, permissions) when is_list(permissions) do
    permissions
    |> Map.new(&{&1, :none})
    |> do_get_search_permissions(claims)
  end

  defp do_get_search_permissions(defaults, %Claims{jti: jti}) do
    session_permissions = TdCache.Permissions.get_session_permissions(jti)
    default_permissions = get_default_permissions(defaults)

    session_permissions
    |> Map.take(Map.keys(defaults))
    |> Map.merge(default_permissions, fn
      _, _, :all -> :all
      _, scope, _ -> scope
    end)
  end

  defp get_default_permissions(defaults) do
    case TdCache.Permissions.get_default_permissions() do
      {:ok, permissions} -> Enum.reduce(permissions, defaults, &Map.replace(&2, &1, :all))
      _ -> defaults
    end
  end
end
