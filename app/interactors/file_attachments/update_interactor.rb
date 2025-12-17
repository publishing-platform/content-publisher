class FileAttachments::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :file_attachment_revision,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      find_file_attachment
      check_for_issues

      update_file_attachment
      update_edition

      update_preview
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:editable?)
  end

  def find_file_attachment
    context.file_attachment_revision = edition.file_attachment_revisions
                                              .find_by!(file_attachment_id: params[:file_attachment_id])
  end

  def check_for_issues
    issues = Requirements::Form::FileAttachmentMetadataChecker.call(attachment_params)
    context.fail!(issues:) if issues.any?
  end

  def update_file_attachment
    updater = Versioning::FileAttachmentRevisionUpdater.new(file_attachment_revision, user)
    updater.assign(
      isbn: attachment_params[:isbn],
      unique_reference: attachment_params[:unique_reference],
    )
    context.file_attachment_revision = updater.next_revision
  end

  def update_edition
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.update_file_attachment(file_attachment_revision)

    context.fail!(unchanged: true) unless updater.changed?

    EditDraftEditionService.call(edition, user, revision: updater.next_revision)
    edition.save!
  end

  def update_preview
    # TODO
    # FailsafeDraftPreviewService.call(edition)
  end

  def attachment_params
    params
      .require(:file_attachment)
      .permit(:isbn, :unique_reference)
  end
end
