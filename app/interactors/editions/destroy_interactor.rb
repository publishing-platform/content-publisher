class Editions::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :api_error,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      discard_draft
    rescue Interactor::Failure
      edition.update!(revision_synced: false)
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:editable?)
  end

  def discard_draft
    DiscardDraftEditionService.call(edition, user)
  rescue PublishingPlatformApi::BaseError => e
    PublishingPlatformError.notify(e)
    context.fail!(api_error: true)
  end
end
