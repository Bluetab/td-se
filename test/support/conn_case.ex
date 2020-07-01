defmodule TdSeWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Phoenix.ConnTest
  alias TdSe.Permissions.MockPermissionResolver
  import TdSe.Authentication, only: :functions

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      alias TdSeWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint TdSeWeb.Endpoint
    end
  end

  @admin_user_name "app-admin"

  setup tags do
    cond do
      tags[:admin_authenticated] ->
        user = create_user(%{user_name: @admin_user_name}, is_admin: true)
        create_user_auth_conn(user)

      tags[:authenticated_user] ->
        user = create_user(tags[:authenticated_user], is_admin: false)
        {:ok, auth_conn} = create_user_auth_conn(user)
        permissions = Map.get(tags[:authenticated_user], :permissions, nil)

        if permissions != nil do
          MockPermissionResolver.put_user_permissions(auth_conn.claims["jti"], permissions)
        end

        {:ok, auth_conn}

      true ->
        {:ok, conn: ConnTest.build_conn()}
    end
  end
end
