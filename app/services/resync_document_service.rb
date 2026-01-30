class ResyncDocumentService
  include Callable

  def initialize(document, **)
    @document = document
  end

  def call
    Edition.transaction do
      sync_live_edition if live_edition
      sync_draft_edition if current_edition != live_edition
    end
  end

private

  delegate :live_edition,
           :current_edition,
           to: :document

  attr_reader :document

  def sync_live_edition
    live_edition.lock!
    PreviewDraftEditionService.call(live_edition, republish: true)
    PublishAssetsService.call(live_edition)

    if live_edition.removed?
      redirect_or_remove
    else
      publish
    end
  end

  def sync_draft_edition
    current_edition.lock!
    FailsafeDraftPreviewService.call(current_edition)
  end

  def publish
    PublishingPlatformApi.publishing_api.publish(live_edition.document.content_id)
  end

  def redirect_or_remove
    removal = live_edition.status.details
    PublishingPlatformApi.publishing_api.unpublish(
      live_edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_url,
      unpublished_at: removal.removed_at,
      allow_draft: true,
    )
  end
end
