# Represents all versions of a piece of content.
# The version of content that is draft or been on Publishing Platform is represented
# as an edition model. Each edit a user has made to content is represented through a
# revision model on an edition.
#
# This model is mutable
class Document < ApplicationRecord
  attr_readonly :content_id

  belongs_to :created_by, class_name: "User"

  has_one :current_edition,
          -> { where(current: true) },
          class_name: "Edition",
          inverse_of: :document

  has_one :live_edition,
          -> { where(live: true) },
          class_name: "Edition",
          inverse_of: :document

  has_many :editions

  has_many :revisions

  scope :with_current_edition, lambda {
    join_tables = { current_edition: %i[revision status] }
    joins(join_tables).includes(join_tables)
  }

  scope :using_base_path, lambda { |base_path|
    left_outer_joins(current_edition: { revision: :content_revision },
                     live_edition: { revision: :content_revision })
      .where("content_revisions.base_path": base_path)
  }

  def next_edition_number
    (editions.maximum(:number) || 0) + 1
  end

  def next_revision_number
    (revisions.maximum(:number) || 0) + 1
  end

  def newly_created?
    return false if !current_edition || !current_edition.first?

    current_edition.created_at == current_edition.updated_at
  end
end
