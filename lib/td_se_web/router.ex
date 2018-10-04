defmodule TdSeWeb.Router do
  use TdSeWeb, :router

  @endpoint_url "#{Application.get_env(:td_se, TdSeWeb.Endpoint)[:url][:host]}:#{
    Application.get_env(:td_se, TdSeWeb.Endpoint)[:url][:port]
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

  scope "/api/swagger" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :td_se, swagger_file: "swagger.json")
  end

  scope "/api", TdSeWeb do
    pipe_through([:api])
    get "/ping", PingController, :ping
  end

  scope "/api", TdSeWeb do
    pipe_through([:api, :api_secure, :api_authorized])
    post "/global_search", SearchController, :global_search
  end

  def swagger_info do
    %{
      schemes: ["http"],
      info: %{
        version: "1.0",
        title: "TdSe"
      },
      host: @endpoint_url,
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
