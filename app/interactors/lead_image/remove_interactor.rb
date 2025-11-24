class LeadImage::RemoveInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           :no_lead_image,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_lead_image

      remove_lead_image

      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:editable?)
    assert_edition_feature(edition, &:lead_image?)
  end

  def check_lead_image
    context.image_revision = edition.lead_image_revision
    context.fail!(no_lead_image: true) unless image_revision
  end

  def remove_lead_image
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(lead_image_revision: nil)

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def update_preview
    # TODO: ?
    # FailsafeDraftPreviewService.call(edition)
  end
end
