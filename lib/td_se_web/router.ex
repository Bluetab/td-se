defmodule TdSeWeb.Router do
  use TdSeWeb, :router

  pipeline :api do
    plug TdSe.Auth.Pipeline.Unsecure
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug TdSe.Auth.Pipeline.Secure
  end

  scope "/api/swagger" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :td_se, swagger_file: "swagger.json")
  end

  scope "/api", TdSeWeb do
    pipe_through :api
    get("/ping", PingController, :ping)
  end

  scope "/api", TdSeWeb do
    pipe_through [:api, :api_auth]
    post("/global_search", SearchController, :global_search)
  end

  def swagger_info do
    %{
      schemes: ["http", "https"],
      info: %{
        version: Application.spec(:td_se, :vsn),
        title: "Truedat Search Service"
      },
      basePath: "/api",
      securityDefinitions: %{
        bearer: %{
          type: "apiKey",
          name: "Authorization",
          in: "header"
        }
      },
      security: [
        %{
          bearer: []
        }
      ]
    }
  end
end
