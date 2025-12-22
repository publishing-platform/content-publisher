class PreviewAssetService
  include Callable

  def initialize(edition, asset, **)
    @edition = edition
    @asset = asset
  end

  def call
    if asset.draft?
      update_asset(asset)
    elsif asset.absent?
      upload_asset(asset)
    end
  rescue PublishingPlatformApi::BaseError => e
    PublishingPlatformError.notify(e)
    raise
  end

private

  attr_reader :edition, :asset

  def update_asset(_asset)
    Payload.new(edition).for_update
    # TODO
    # PublishingPlatformApi.asset_manager.update_asset(asset.asset_manager_id, payload)
  end

  def upload_asset(asset)
    Payload.new(edition).for_upload(asset)
    # TODO
    # upload = PublishingPlatformApi.asset_manager.create_asset(payload)
    # asset.update!(file_url: upload["file_url"], state: :draft)
  end
end
