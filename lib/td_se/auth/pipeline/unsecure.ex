defmodule TdSe.Auth.Pipeline.Unsecure do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :td_se,
    error_handler: TdSe.Auth.ErrorHandler,
    module: TdSe.Auth.Guardian

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
