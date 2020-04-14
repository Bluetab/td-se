defmodule Mix.Tasks.Se.EsInit do
  @moduledoc """
  Run elastic initialization
  """

  use Mix.Task

  alias TdSe.ESClientApi

  @shortdoc "Create test mappings in elasticsearch"
  def run(__args) do
    Mix.Task.run("app.start")
    ESClientApi.create_indexes()
    ESClientApi.create_aliases()
  end
end
