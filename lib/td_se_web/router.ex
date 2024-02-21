defmodule TdSeWeb.Router do
  use TdSeWeb, :router

  pipeline :api do
    plug(TdCore.Auth.Pipeline.Unsecure)
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug(TdCore.Auth.Pipeline.Secure)
  end

  scope "/api", TdSeWeb do
    pipe_through :api
    get("/ping", PingController, :ping)
  end

  scope "/api", TdSeWeb do
    pipe_through [:api, :api_auth]
    post("/global_search", SearchController, :global_search)

    get "/elastic_indexes", ElasticIndexController, :index
    delete "/elastic_indexes/:index_name", ElasticIndexController, :delete
  end
end
