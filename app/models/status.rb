# Used to represent the user facing status of an edition. Each status an
# edition has is stored and it must always have one.
class Status < ApplicationRecord
  attr_readonly :state, :revision_at_creation_id

  belongs_to :created_by, class_name: "User"

  belongs_to :revision_at_creation, class_name: "Revision"

  belongs_to :edition, optional: true

  has_and_belongs_to_many :revisions

  enum :state, { draft: "draft",
                 submitted_for_review: "submitted_for_review",
                 published: "published",
                 published_but_needs_2i: "published_but_needs_2i",
                 removed: "removed",
                 discarded: "discarded",
                 superseded: "superseded",
                 failed_to_publish: "failed_to_publish" }

  def live?
    %w[published published_but_needs_2i removed].include?(state)
  end
end
