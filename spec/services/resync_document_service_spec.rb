require "rails_helper"

RSpec.describe ResyncDocumentService do
  describe ".call" do
    before do
      stub_any_publishing_api_publish
      stub_any_publishing_api_put_content
    end

    context "when there is no live edition" do
      let(:edition) { create(:edition) }

      it "doesn't publish the edition" do
        expect(FailsafeDraftPreviewService).to receive(:call).with(edition)
        expect(PublishingPlatformApi.publishing_api).not_to receive(:publish)
        described_class.call(edition.document)
      end
    end

    context "when the current edition is live" do
      let(:edition) { create(:edition, :published) }

      it "avoids synchronising the edition twice" do
        expect(PreviewDraftEditionService).to receive(:call).once
        described_class.call(edition.document)
      end

      it "re-publishes the live edition" do
        expect(PreviewDraftEditionService).to receive(:call)
                              .with(edition, republish: true)
                              .and_call_original

        request = stub_publishing_api_publish(edition.content_id, {})
        described_class.call(edition.document)

        expect(request).to have_been_requested
      end

      it "publishes assets to the live stack" do
        expect(PublishAssetsService).to receive(:call).once.with(edition)
        described_class.call(edition.document)
      end
    end

    context "when the live edition has been removed" do
      let(:explanation) { "explanation" }

      before do
        stub_any_publishing_api_unpublish
      end

      context "with a redirect" do
        let(:removal) do
          build(
            :removal,
            redirect: true,
            alternative_url: "/foo/bar",
            explanatory_note: explanation,
          )
        end

        let(:edition) { create(:edition, :removed, removal:) }

        it "removes and redirects the edition" do
          remove_params = {
            type: "redirect",
            explanation:,
            alternative_path: removal.alternative_url,
            unpublished_at: removal.removed_at,
            allow_draft: true,
          }

          request = stub_publishing_api_unpublish(edition.content_id, body: remove_params)
          described_class.call(edition.document)

          expect(request).to have_been_requested
        end
      end

      context "without a redirect" do
        let(:edition) { create(:edition, :removed, removal: build(:removal)) }

        it "removes the edition" do
          remove_params = {
            type: "gone",
            unpublished_at: edition.status.details.removed_at,
            allow_draft: true,
          }

          request = stub_publishing_api_unpublish(edition.content_id, body: remove_params)
          described_class.call(edition.document)

          expect(request).to have_been_requested
        end
      end
    end
  end
end
