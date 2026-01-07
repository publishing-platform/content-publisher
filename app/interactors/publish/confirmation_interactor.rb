class Publish::ConfirmationInteractor < ApplicationInteractor
  delegate :user,
           :params,
           :edition,
           :api_error,
           :issues,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:editable?)
  end

  def check_for_issues
    issues = Requirements::Publish::EditionChecker.call(edition)
    context.fail!(issues:) if issues.any?
  rescue PublishingPlatformApi::BaseError => e
    PublishingPlatformError.notify(e)
    context.fail!(api_error: true)
  end
end
