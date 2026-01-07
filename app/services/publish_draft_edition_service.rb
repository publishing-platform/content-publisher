class PublishDraftEditionService
  include Callable

  def initialize(edition, user, with_review:)
    @edition = edition
    @user = user
    @with_review = with_review
  end

  def call
    raise "Only a current edition can be published" unless edition.current?
    raise "Live editions cannot be published" if edition.live?

    publish_assets
    set_published_at
    publish_current_edition
    supersede_live_edition
    set_new_live_edition
  rescue PublishingPlatformApi::BaseError => e
    PublishingPlatformError.notify(e)
    raise
  end

private

  attr_reader :edition, :user, :with_review

  delegate :document, to: :edition

  def publish_assets
    PublishAssetsService.call(edition, superseded_edition: document.live_edition)
  end

  def publish_current_edition
    PublishingPlatformApi.publishing_api.publish(document.content_id)
  end

  def supersede_live_edition
    live_edition = document.live_edition
    return unless live_edition

    AssignEditionStatusService.call(live_edition,
                                    user:,
                                    state: :superseded,
                                    record_edit: false)
    live_edition.live = false
    live_edition.save!
  end

  def set_new_live_edition
    state = with_review ? :published : :published_but_needs_2i
    AssignEditionStatusService.call(edition, user:, state:)
    edition.live = true
    edition.save!
    document.reload_live_edition
  end

  def set_published_at
    current_time = Time.zone.now
    edition.published_at = current_time

    return if document.first_published_at

    document.update!(first_published_at: current_time)
  end
end
