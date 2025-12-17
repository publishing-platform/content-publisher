# Respresents the current state of a piece of content that was once or is
# expected to be published on Publishing Platform.
#
# It is a mutable concept that is associated with a revision model and status
# model to represent the current content and state of the edition.
class Edition < ApplicationRecord
  before_create do
    # set a default value for last_edited_at works better than using DB default
    self.last_edited_at = Time.zone.now unless last_edited_at
  end

  after_save do
    # Store the edition on the status to keep a history
    status.update!(edition: self) unless status.edition_id

    # Used to keep an audit trail of statuses a revision has held
    revision.statuses << status unless revision.statuses.include?(status)

    # An edition points to a single revision, however we want to mantain a log
    # of all joins between revision and edition. Revision has a many-to-many
    # edition association that we use for storing this (to avoid the complexity
    # of an edition having revision and revsions methods). Typically a revision
    # would only be associated with a single edition.
    revision.editions << self unless revision.editions.include?(self)
  end

  attr_readonly :number, :document_id

  attribute :auth_bypass_id, default: -> { SecureRandom.uuid }

  belongs_to :created_by, class_name: "User"

  belongs_to :last_edited_by, class_name: "User"

  belongs_to :document

  belongs_to :revision

  belongs_to :status

  has_and_belongs_to_many :revisions

  has_many :statuses

  has_and_belongs_to_many :editors,
                          class_name: "User",
                          join_table: :edition_editors

  delegate :content_id, to: :document

  # delegate each state enum method
  state_methods = Status.states.keys.map { |s| "#{s}?".to_sym }
  delegate :state, *state_methods, to: :status

  delegate :title,
           :title_or_fallback,
           :base_path,
           :document_type,
           :summary,
           :contents,
           :update_type,
           :change_note,
           :change_history,
           :major?,
           :minor?,
           :tags,
           :lead_image_revision,
           :image_revisions,
           :image_revisions_without_lead,
           :file_attachment_revisions,
           :assets,
           :primary_publishing_organisation_id,
           :featured_attachments,
           :featured_attachment_ordering,
           to: :revision

  scope :find_current, lambda { |document_id: nil|
    join_tables = %i[document revision status]
    where(current: true)
      .joins(join_tables)
      .includes(join_tables)
      .find_by!(document_id:)
  }

  def editable?
    !live?
  end

  def first?
    number == 1
  end

  def public_first_published_at
    document.first_published_at
  end

  def add_edition_editor(user)
    return unless user

    editors << user unless editors.include?(user)
  end

  def auth_bypass_token
    JWT.encode(
      {
        "sub" => auth_bypass_id,
        "content_id" => content_id,
        "iat" => Time.zone.now.to_i,
        "exp" => 1.month.from_now.to_i,
      },
      Rails.application.credentials.jwt_auth_secret,
      "HS256",
    )
  end
end
