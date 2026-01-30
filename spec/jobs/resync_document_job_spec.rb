require "rails_helper"

RSpec.describe ResyncDocumentJob do
  let(:document) { create(:document) }

  it "delegates to the ResyncDocumentService" do
    expect(ResyncDocumentService)
      .to receive(:call)
      .with(document)
    described_class.perform_now(document)
  end

  it "retries the job when an exception is raised" do
    allow(ResyncDocumentService).to receive(:call).and_raise(PublishingPlatformApi::BaseError)
    described_class.perform_now(document)

    expect(described_class).to have_been_enqueued
  end
end
