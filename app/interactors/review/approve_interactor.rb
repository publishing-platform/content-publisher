class Review::ApproveInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :wrong_status,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      approve_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:published_but_needs_2i?)
  end

  def approve_edition
    AssignEditionStatusService.call(edition, user:, state: :published)
    edition.save!
  end
end
