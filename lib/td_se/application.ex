defmodule TdSe.Application do
  @moduledoc false

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    env = Application.get_env(:td_se, :env)

    # Define workers and child supervisors to be supervised
    children = [TdSeWeb.Endpoint] ++ children(env)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TdSe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def children(:test), do: []

  def children(_env) do
    # Elasticsearch worker
    [TdSe.Search.Cluster]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TdSeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
