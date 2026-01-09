class Editions::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :next_edition,
           :discarded_edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      create_next_edition
      # preview_next_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    context.discarded_edition = Edition.find_by(document_id: edition.document_id,
                                                number: edition.number + 1)
    assert_edition_state(edition, assertion: "can create new edition") { edition.live }
  end

  def create_next_edition
    context.next_edition = CreateNextEditionService.call(current_edition: edition,
                                                         user:,
                                                         discarded_edition:)
  end

  # TODO: ?
  # def preview_next_edition
  #   FailsafeDraftPreviewService.call(next_edition)
  # end
end
