# Represents a particular revision of a document - acting as a snapshot to
# a particular user's edit.
#
# This model stores as little data as possible by having associations to more
# specific types of revision and delegating its methods to them.
#
# This model is immutable
class Revision < ApplicationRecord
  COMPARISON_IGNORE_FIELDS = %w[id number created_at created_by_id].freeze

  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :document

  belongs_to :content_revision

  belongs_to :metadata_revision

  belongs_to :tags_revision

  belongs_to :preceded_by,
             class_name: "Revision",
             optional: true

  has_and_belongs_to_many :statuses, -> { order("statuses.created_at DESC") }

  has_and_belongs_to_many :editions, -> { order("editions.number DESC") }

  delegate :title,
           :base_path,
           :summary,
           :contents,
           :title_or_fallback,
           to: :content_revision

  delegate :update_type,
           :change_note,
           :change_history,
           :major?,
           :minor?,
           :document_type,
           to: :metadata_revision

  delegate :tags,
           :primary_publishing_organisation_id,
           to: :tags_revision

  def readonly?
    !new_record?
  end
end
