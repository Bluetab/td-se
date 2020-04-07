defmodule TdSe.BusinessConcepts.BusinessConcept do
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
      view_approval_pending_business_concepts: @status.pending_approval,
      view_deprecated_business_concepts: @status.deprecated,
      view_draft_business_concepts: @status.draft,
      view_published_business_concepts: @status.published,
      view_rejected_business_concepts: @status.rejected,
      view_versioned_business_concepts: @status.versioned
    }
  end

  def default_status do
    [Map.get(@status, :published)]
  end
end
