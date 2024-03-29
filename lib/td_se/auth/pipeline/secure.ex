defmodule TdSe.Auth.Pipeline.Secure do
  @moduledoc """
  Plug pipeline for routes requiring authentication
  """

  use Guardian.Plug.Pipeline,
    otp_app: :td_se,
    error_handler: TdCore.Auth.ErrorHandler,
    module: TdCore.Auth.Guardian

  plug Guardian.Plug.EnsureAuthenticated, claims: %{"aud" => "truedat", "iss" => "tdauth"}
  plug Guardian.Plug.LoadResource
  plug TdSe.Auth.Plug.SessionExists
  plug TdSe.Auth.Plug.CurrentResource
end
