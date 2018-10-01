defmodule TdSeWeb.PingController do
  use TdSeWeb, :controller

  action_fallback(TdSeWeb.FallbackController)

  def ping(conn, _params) do
    send_resp(conn, 200, "pong")
  end
end
