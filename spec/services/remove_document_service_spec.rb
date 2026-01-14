RSpec.describe RemoveDocumentService do
  describe "#call" do
    let(:edition) { create(:edition, :published) }
    let(:user) { create(:user) }

    before { stub_any_publishing_api_unpublish }

    it "calls the Publishing API unpublish method" do
      request = stub_publishing_api_unpublish(
        edition.content_id,
        body: hash_including(type: "gone"),
      )
      described_class.call(edition, user:)
      expect(request).to have_been_requested
    end

    it "updates the edition status" do
      expect { described_class.call(edition, user:) }
        .to change(edition, :state)
        .to("removed")
    end

    it "can assign a user to the status" do
      described_class.call(edition, user:)
      expect(edition.status.created_by).to eq(user)
    end

    context "when the removal is a redirect" do
      it "unpublishes in the Publishing API with a type of redirect" do
        freeze_time do
          request = stub_publishing_api_unpublish(
            edition.content_id,
            body: {
              alternative_path: "/path",
              type: "redirect",
              unpublished_at: Time.zone.now.utc.iso8601,
              discard_drafts: true,
            },
          )
          described_class.call(edition, redirect_url: "/path", user:)
          expect(request).to have_been_requested
        end
      end
    end

    context "when the removal is not a redirect" do
      it "unpublishes in the Publishing API with a type of gone" do
        freeze_time do
          request = stub_publishing_api_unpublish(
            edition.content_id,
            body: {
              type: "gone",
              unpublished_at: Time.zone.now,
              discard_drafts: true,
            },
          )
          described_class.call(edition, user:)
          expect(request).to have_been_requested
        end
      end
    end

    context "when Publishing API is down" do
      before { stub_publishing_api_isnt_available }

      it "doesn't change the editions state" do
        expect { described_class.call(edition, user:) }
          .to raise_error(PublishingPlatformApi::BaseError)
        expect(edition.reload.state).to eq("published")
      end
    end

    context "when an edition has assets" do
      # rubocop:disable RSpec/RepeatedExample
      it "removes assets that aren't absent" do
        image_revision = create(:image_revision, :on_asset_manager, state: :live)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :live)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        # TODO
        # delete_request = stub_asset_manager_deletes_any_asset

        described_class.call(edition, user:)

        # TODO
        # expect(delete_request).to have_been_requested.at_least_once
        expect(image_revision.assets.map(&:state).uniq).to eq(%w[absent])
        expect(file_attachment_revision.asset).to be_absent
      end

      it "copes with assets that 404" do
        image_revision = create(:image_revision, :on_asset_manager, state: :live)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :live)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        # TODO
        # delete_request = stub_asset_manager_deletes_any_asset.to_return(status: 404)

        described_class.call(edition, user:)

        # TODO
        # expect(delete_request).to have_been_requested.at_least_once
        expect(image_revision.assets.map(&:state).uniq).to eq(%w[absent])
        expect(file_attachment_revision.asset).to be_absent
      end
      # rubocop:enable RSpec/RepeatedExample

      it "ignores assets that are absent" do
        image_revision = create(:image_revision, :on_asset_manager, state: :absent)
        file_attachment_revision = create(:file_attachment_revision, :on_asset_manager, state: :absent)
        edition = create(:edition,
                         :published,
                         lead_image_revision: image_revision,
                         file_attachment_revisions: [file_attachment_revision])

        delete_request = stub_asset_manager_deletes_any_asset

        described_class.call(edition, user:)

        expect(delete_request).not_to have_been_requested
      end
    end

    # TODO
    # context "when an edition has assets and Asset Manager is down" do
    #   before { stub_asset_manager_isnt_available }

    #   it "removes the edition" do
    #     image_revision = create(:image_revision, :on_asset_manager)
    #     file_attachment_revision = create(:file_attachment_revision, :on_asset_manager)
    #     edition = create(:edition,
    #                      :published,
    #                      lead_image_revision: image_revision,
    #                      file_attachment_revisions: [file_attachment_revision])

    #     expect { described_class.call(edition, user:) }
    #       .to raise_error(PublishingPlatformApi::BaseError)

    #     expect(edition.reload.state).to eq("removed")
    #   end
    # end

    context "when the given edition is a draft" do
      it "raises an error" do
        draft_edition = create(:edition)
        expect { described_class.call(draft_edition, user:) }
          .to raise_error "attempted to remove an edition other than the live edition"
      end
    end
  end
end
