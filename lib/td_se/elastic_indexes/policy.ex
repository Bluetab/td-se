defmodule TdSe.ElasticIndexes.Policy do
  @moduledoc "Authorization rules for TdSe.ElasticIndexes"

  @behaviour Bodyguard.Policy

  # Admin accounts can do anything
  def authorize(_action, %{role: "admin"}, _params), do: true

  # No other users can do nothing
  def authorize(_action, _claims, _params), do: false
end
