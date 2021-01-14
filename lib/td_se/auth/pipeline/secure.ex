defmodule TdSe.Auth.Pipeline.Secure do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :td_se,
    error_handler: TdSe.Auth.ErrorHandler,
    module: TdSe.Auth.Guardian

  plug(Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access"})
  plug(TdSe.Auth.CurrentResource)
end
