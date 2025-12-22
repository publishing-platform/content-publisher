class DeleteDraftAssetsService
  include Callable

  def initialize(edition, **)
    @edition = edition
  end

  def call
    edition.assets.each do |asset|
      next unless asset.draft?

      begin
        # TODO
        # PublishingPlatformApi.asset_manager.delete_asset(asset.asset_manager_id)
      rescue PublishingPlatformApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end
      asset.absent!
    end
  end

private

  attr_reader :edition
end
