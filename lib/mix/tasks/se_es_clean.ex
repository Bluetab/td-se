defmodule Mix.Tasks.Se.EsClean do
  use Mix.Task
  alias TdSe.ESClientApi

  @moduledoc """
    Run elastic clean
  """

  @shortdoc "Create test mappings in elasticsearch"
  def run(__args) do
    Mix.Task.run "app.start"
    ESClientApi.delete_indexes
    ESClientApi.delete_aliases
  end
end
