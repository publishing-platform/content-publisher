class Images::DestroyInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :removed_lead_image,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_and_remove_image
      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:editable?)
  end

  def find_and_remove_image
    context.image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.remove_image(image_revision)
    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
    context.removed_lead_image = updater.removed_lead_image?
  end

  def update_preview
    # TODO: ?
    # FailsafeDraftPreviewService.call(edition)
  end
end
