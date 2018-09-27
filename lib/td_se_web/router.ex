defmodule TdSeWeb.Router do
  use TdSeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TdSeWeb do
    pipe_through :api
  end
end
