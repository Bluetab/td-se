defmodule TdSe.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    env = Application.get_env(:td_se, :env)

    # Define workers and child supervisors to be supervised
    children = [TdSeWeb.Endpoint] ++ children(env)

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

  defp children(:test), do: []

  defp children(_env) do
    # Elasticsearch worker
    [TdSe.Search.Cluster]
  end
end
