class Review::SubmitFor2iInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :api_error,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues

      update_status
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])
    assert_edition_state(edition, &:draft?)
  end

  def check_for_issues
    issues = Requirements::Publish::EditionChecker.call(edition)
    context.fail!(issues:) if issues.any?
  rescue PublishingPlatformApi::BaseError => e
    PublishingPlatformError.notify(e)
    context.fail!(api_error: true)
  end

  def update_status
    AssignEditionStatusService.call(edition, user:, state: :submitted_for_review)
    edition.save!
  end
end
