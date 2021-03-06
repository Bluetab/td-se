defmodule TdSe.Permissions do
  @moduledoc """
  The Permissions context.
  """

  alias TdSe.Auth.Claims

  @permission_resolver Application.compile_env(:td_se, :permission_resolver)

  def get_domain_permissions(%Claims{jti: jti}) do
    @permission_resolver.get_acls_by_resource_type(jti, "domain")
  end
end
