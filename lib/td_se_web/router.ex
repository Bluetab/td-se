defmodule TdSeWeb.Router do
  use TdSeWeb, :router

  pipeline :api do
    plug(TdSe.Auth.Pipeline.Unsecure)
    plug(:accepts, ["json"])
  end

  pipeline :api_secure do
    plug(TdSe.Auth.Pipeline.Secure)
  end

  pipeline :api_authorized do
    plug(TdSe.Auth.CurrentResource)
    plug(Guardian.Plug.LoadResource)
  end

  scope "/api", TdSeWeb do
    pipe_through([:api, :api_secure, :api_authorized])
  end
end
