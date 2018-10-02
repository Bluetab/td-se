defmodule TdSe.GlobalSearchTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias TdPerms.MockPermissionResolver
  alias TdSe.ESClientApi
  use TdSeWeb.ConnCase

  @user_permissions [%{
    permissions: [:view_draft_business_concepts, :view_published_business_concepts],
    resource_id: 2,
    resource_type: "domain"
  },
  %{
    permissions: [:view_draft_business_concepts, :view_published_business_concepts],
    resource_id: 3,
    resource_type: "domain"
  },
  %{
    permissions: [:view_draft_business_concepts, :view_published_business_concepts],
    resource_id: 5,
    resource_type: "domain"
  }
]

  setup_all do
    start_supervised MockPermissionResolver
    :ok
  end

  setup do
    bulk_list =
      :code.priv_dir(:td_se)
      |> Path.join("static/bulk_content.json")
      |> File.read!()
      |> Poison.decode!()
      |> Map.fetch!("bulk_list")

    ESClientApi.bulk_index_content(bulk_list)
    :ok
  end

  describe "Search test" do
    @tag authenticated_user: %{user_name: "not_admin_user", permissions: @user_permissions}
    test "list indexes on wich a not admit user has permissions" do
      assert true
    end
  end

end
