defmodule Mix.Tasks.Se.EsInit do
  @moduledoc """
  Run elastic initialization
  """

  use Mix.Task

  alias ElasticsearchSupport

  @shortdoc "Create test mappings in elasticsearch"
  def run(__args) do
    Mix.Task.run("app.start")
    ElasticsearchSupport.create_indexes()
    ElasticsearchSupport.create_aliases()
  end
end
