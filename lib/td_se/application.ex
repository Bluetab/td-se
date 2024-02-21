defmodule TdSe.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [TdSeWeb.Endpoint]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TdSe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TdSeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
