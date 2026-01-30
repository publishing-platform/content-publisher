class ResyncDocumentJob < ApplicationJob
  retry_on(
    PublishingPlatformApi::BaseError,
    attempts: 5,
    wait: :polynomially_longer,
  ) { |_job, error| PublishingPlatformError.notify(error) }

  def perform(document)
    ResyncDocumentService.call(document)
  end
end
