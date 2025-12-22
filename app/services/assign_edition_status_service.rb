class AssignEditionStatusService
  include Callable

  def initialize(edition,
                 state:,
                 user: nil,
                 record_edit: true)
    @edition = edition
    @user = user
    @state = state
    @record_edit = record_edit
  end

  def call
    edition.status = Status.new(created_by: user,
                                state:,
                                revision_at_creation: edition.revision)

    if record_edit
      edition.last_edited_by = user
      edition.last_edited_at = Time.zone.now
      edition.add_edition_editor(user)
    end
  end

private

  attr_reader :edition, :user, :state, :record_edit
end
