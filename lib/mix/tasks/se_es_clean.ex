defmodule Mix.Tasks.Se.EsClean do
  @moduledoc """
  Run elastic clean
  """

  use Mix.Task

  alias ElasticsearchSupport

  @shortdoc "Create test mappings in elasticsearch"
  def run(__args) do
    Mix.Task.run("app.start")
    ElasticsearchSupport.delete_aliases()
    ElasticsearchSupport.delete_indexes()
  end
end
