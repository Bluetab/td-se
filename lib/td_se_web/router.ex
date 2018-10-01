defmodule TdSeWeb.Router do
  use TdSeWeb, :router

  @endpoint_url "#{Application.get_env(:td_se, TdLmWeb.Endpoint)[:url][:host]}:#{
    Application.get_env(:td_se, TdLmWeb.Endpoint)[:url][:port]
  }"

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
    pipe_through([:api])
    get "/ping", PingController, :ping
  end

  scope "/api", TdSeWeb do
    pipe_through([:api, :api_secure, :api_authorized])
    post "/global_search", SearchController, :global_search
  end

end
