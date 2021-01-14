defmodule TdSe.Authentication do
  @moduledoc """
  This module defines the functions required to add auth headers to requests in
  the tests
  """

  import Plug.Conn

  alias Phoenix.ConnTest
  alias TdSe.Auth.Claims
  alias TdSe.Auth.Guardian

  def put_auth_headers(conn, jwt) do
    conn
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "Bearer #{jwt}")
  end

  def create_user_auth_conn(%{role: role} = claims) do
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(claims, %{role: role})
    {:ok, claims} = Guardian.resource_from_claims(full_claims)

    conn =
      ConnTest.build_conn()
      |> put_auth_headers(jwt)

    {:ok, %{conn: conn, jwt: jwt, claims: claims}}
  end

  def create_claims(user_name, opts \\ []) do
    user_id = Integer.mod(:binary.decode_unsigned(user_name), 100_000)
    role = Keyword.get(opts, :role, "user")

    %Claims{
      user_id: user_id,
      user_name: user_name,
      role: role
    }
  end
end
