# TODO
class DeleteDraftAssetsService
  include Callable

  def initialize(edition, **)
    @edition = edition
  end

  def call; end

private

  attr_reader :edition
end
