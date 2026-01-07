RSpec.describe PublishDraftEditionService do
  describe ".call" do
    let(:user) { create(:user) }

    before do
      stub_any_publishing_api_publish
      allow(PreviewDraftEditionService).to receive(:call)
      allow(PublishAssetsService).to receive(:call)
    end

    context "when there is no live edition" do
      let(:edition) { create(:edition, :publishable) }

      it "publishes the current_edition" do
        publish_request = stub_publishing_api_publish(edition.content_id, {})

        described_class.call(edition, user, with_review: true)
        expect(publish_request).to have_been_requested
        expect(edition.document.live_edition).to eq(edition)
        expect(edition).to be_published
        expect(edition).to be_live
      end

      it "sets the document first publishing time" do
        freeze_time do
          expect { described_class.call(edition, user, with_review: true) }
            .to change(edition.document, :first_published_at).to(Time.zone.now)
        end
      end

      it "can specify if edition is reviewed" do
        described_class.call(edition, user, with_review: false)
        expect(edition).to be_published_but_needs_2i
      end
    end

    context "when there is a live edition" do
      let(:document) { create(:document, :with_current_and_live_editions) }

      it "supersedes the live edition" do
        live_edition = document.live_edition
        described_class.call(document.current_edition, user, with_review: true)
        expect(live_edition).to be_superseded
      end

      it "doesn't overwrite when the document was first published" do
        expect { described_class.call(document.current_edition, user, with_review: true) }
          .not_to change(document, :first_published_at)
      end
    end

    it "sets the current edition's published_at time" do
      document = create(:document, :with_current_edition)
      freeze_time do
        expect { described_class.call(document.current_edition, user, with_review: true) }
          .to change(document.current_edition, :published_at).to(Time.zone.now)
      end
    end

    it "updates the document's live edition to be the current edition" do
      document = create(:document, :with_current_edition)
      expect { described_class.call(document.current_edition, user, with_review: true) }
        .to change(document, :live_edition).to(document.current_edition)
    end

    it "calls the PublishAssetsService" do
      document = create(:document, :with_current_and_live_editions)
      current_edition = document.current_edition
      expect(PublishAssetsService).to receive(:call)
      described_class.call(current_edition, user, with_review: true)
    end

    it "raises an error when the edition is not current" do
      edition = build(:edition, current: false)
      expect { described_class.call(edition, user, with_review: true) }
        .to raise_error("Only a current edition can be published")
    end

    it "raises an error when the edition is already live" do
      edition = build(:edition, live: true)
      expect { described_class.call(edition, user, with_review: true) }
        .to raise_error("Live editions cannot be published")
    end
  end
end
