class RemoveDocumentService
  include Callable

  def initialize(edition, redirect_url: nil, user: nil)
    @edition = edition
    @redirect_url = redirect_url
    @user = user
  end

  def call
    Document.transaction do
      edition.document.lock!
      check_removeable
      unpublish_edition
      update_edition_status
    end

    delete_assets
  end

private

  attr_reader :edition, :redirect_url, :user

  def unpublish_edition
    PublishingPlatformApi.publishing_api.unpublish(
      edition.content_id,
      type: redirect_url.present? ? "redirect" : "gone",
      alternative_path: redirect_url,
      unpublished_at: Time.zone.now,
      discard_drafts: true,
    )
  end

  def update_edition_status
    AssignEditionStatusService.call(edition,
                                    state: :removed,
                                    user:)
    edition.save!
  end

  def check_removeable
    unless edition.live?
      raise "attempted to remove an edition other than the live edition"
    end
  end

  def delete_assets
    edition.assets.each do |asset|
      next if asset.absent?

      begin
        # TODO
        # PublishingPlatformApi.asset_manager.delete_asset(asset.asset_manager_id)
      rescue PublishingPlatformApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end

      asset.absent!
    end
  end
end
