class LeadImage::ChooseInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :image_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_image_revision

      choose_lead_image

      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:editable?)
    assert_edition_feature(edition, &:lead_image?)
  end

  def find_image_revision
    context.image_revision = edition.image_revisions.find_by!(image_id: params[:image_id])
  end

  def choose_lead_image
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(lead_image_revision: image_revision)

    context.fail! unless updater.changed?

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def update_preview
    # TODO: ?
    # FailsafeDraftPreviewService.call(edition)
  end
end
