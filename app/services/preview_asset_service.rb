# TODO
class PreviewAssetService
  include Callable

  def initialize(edition, asset, **)
    @edition = edition
    @asset = asset
  end

  def call; end
end
