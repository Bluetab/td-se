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

  setup tags do
    case tags[:authentication] do
      nil ->
        [conn: ConnTest.build_conn()]

      auth_opts ->
        auth_opts
        |> create_claims()
        |> create_user_auth_conn()
        |> assign_permissions(auth_opts[:permissions])
    end
  end
end
