RSpec.describe PreviewAssetService::Payload do
  describe "#for_update" do
    it "returns a payload hash" do
      edition = build :edition
      payload = described_class.new(edition).for_update

      expect(payload).to match(
        draft: true,
        auth_bypass_ids: [edition.auth_bypass_id],
      )
    end
  end

  describe "#for_upload" do
    let(:asset) do
      double(bytes: "bytes", content_type: "image/png") # rubocop:disable RSpec/VerifiedDoubles, Lint/RedundantCopDisableDirective
    end

    it "returns a payload hash" do
      edition = build :edition
      payload = described_class.new(edition).for_upload(asset)

      expect(payload).to match(
        content_type: "image/png",
        draft: true,
        auth_bypass_ids: [edition.auth_bypass_id],
        file: instance_of(PreviewAssetService::UploadedFile),
      )
    end
  end
end
