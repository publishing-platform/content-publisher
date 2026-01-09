RSpec.describe Editions::CreateInteractor do
  describe ".call" do
    let(:user) { create :user }

    before do
      stub_any_publishing_api_put_content
    end

    it "resets the edition metadata" do
      edition = create(:edition,
                       live: true,
                       change_note: "note",
                       update_type: :minor)

      params = { document_id: edition.document_id }

      next_edition = described_class
        .call(params:, user:)
        .next_edition

      expect(next_edition.update_type).to eq "major"
      expect(next_edition.change_note).to be_empty
      expect(next_edition).to be_draft
      expect(next_edition).to be_current
    end

    # TODO: ?
    # it "sends a preview of the new edition to the Publishing API" do
    #   old_edition = create(:edition, :published)

    #   expect(FailsafeDraftPreviewService).to receive(:call)
    #   expect(FailsafeDraftPreviewService).not_to receive(:call).with(old_edition)

    #   described_class
    #     .call(params: { document: old_edition.document.to_param }, user:)
    # end

    context "when the edition was discarded" do
      let(:live_edition) { create(:edition, :published) }
      let(:params) { { document_id: live_edition.document_id } }

      let!(:discarded_edition) do
        create(:edition,
               state: "discarded",
               current: false,
               document: live_edition.document)
      end

      it "delegates to the CreateNextEditionService" do
        expect(CreateNextEditionService)
          .to receive(:call)
          .with(current_edition: live_edition,
                user:,
                discarded_edition:)
          .and_call_original
        described_class.call(params:, user:)
      end
    end

    context "when there is not a discarded edition" do
      let(:edition) { create(:edition, :published, number: 2) }
      let(:params) { { document_id: edition.document_id } }

      it "delegates to the CreateNextEditionService" do
        expect(CreateNextEditionService)
          .to receive(:call)
          .with(current_edition: edition, user:, discarded_edition: nil)
          .and_call_original
        described_class.call(params:, user:)
      end
    end
  end
end
