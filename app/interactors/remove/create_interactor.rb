class Remove::CreateInteractor < ApplicationInteractor
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
      remove_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(document_id: params[:document_id])

    assert_edition_state(edition, assertion: "is published") do
      edition.published? || edition.published_but_needs_2i?
    end
  end

  def check_for_issues
    issues = Requirements::Form::RemovalChecker.call(edition, relative_redirect_url)
    context.fail!(issues:) if issues.any?
  end

  def remove_edition
    removal = Removal.new(alternative_url: relative_redirect_url,
                          redirect: relative_redirect_url.present?)
    RemoveDocumentService.call(edition,
                               removal,
                               user:)
  rescue PublishingPlatformApi::BaseError => e
    PublishingPlatformError.notify(e)
    context.fail!(api_error: true)
  end

  def relative_redirect_url
    params[:redirect_url].presence&.sub(%r{^(https?://)?(www\.)?publishing-platform\.co\.uk/}, "/")
  end
end
