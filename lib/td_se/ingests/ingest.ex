defmodule TdSe.Ingests.Ingest do
  @moduledoc false

  @status %{
    draft: "draft",
    pending_approval: "pending_approval",
    rejected: "rejected",
    published: "published",
    versioned: "versioned",
    deprecated: "deprecated"
  }

  def permissions_to_status do
    %{
      view_approval_pending_ingests: @status.pending_approval,
      view_deprecated_ingests: @status.deprecated,
      view_draft_ingests: @status.draft,
      view_published_ingests: @status.published,
      view_rejected_ingests: @status.rejected,
      view_versioned_ingests: @status.versioned
    }
  end

  def default_status do
    [Map.get(@status, :published)]
  end
end
