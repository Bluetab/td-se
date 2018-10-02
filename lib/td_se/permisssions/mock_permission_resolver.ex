defmodule TdPerms.MockPermissionResolver do
  @moduledoc """
    A mock permissions resolver
  """
  use Agent
  alias Poision

  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: :MockPermissions)
  end

  def get_acls_by_resource_type(_session_id, _resource_type) do

  end

  def put_user_permissions(session_id, permissions) do
    Agent.update(:MockPermissions, &Map.put(&1, session_id, permissions))
  end
end
