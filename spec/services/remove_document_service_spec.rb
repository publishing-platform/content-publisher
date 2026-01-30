require "rails_helper"

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
      described_class.call(edition, build(:removal), user:)
      expect(request).to have_been_requested
    end

    it "updates the edition status" do
      removal = build(:removal)

      expect { described_class.call(edition, removal, user:) }
        .to change(edition, :state)
        .to("removed")

      expect(edition.status.details).to eq(removal)
    end

    it "can assign a user to the status" do
      described_class.call(edition, build(:removal), user:)
      expect(edition.status.created_by).to eq(user)
    end

    context "when the removal is a redirect" do
      it "unpublishes in the Publishing API with a type of redirect" do
        freeze_time do
          removal = build(:removal,
                          redirect: true,
                          alternative_url: "/path",
                          explanatory_note: "explanation")

          request = stub_publishing_api_unpublish(
            edition.content_id,
            body: {
              alternative_path: "/path",
              explanation: "explanation",
              type: "redirect",
              unpublished_at: Time.zone.now.utc,
            },
          )
          described_class.call(edition, removal, user:)
          expect(request).to have_been_requested
        end
      end
    end

    context "when the removal is not a redirect" do
      it "unpublishes in the Publishing API with a type of gone" do
        freeze_time do
          removal = build(:removal,
                          redirect: false,
                          alternative_url: "/path",
                          explanatory_note: "explanation")

          request = stub_publishing_api_unpublish(
            edition.content_id,
            body: {
              alternative_path: "/path",
              explanation: "explanation",
              type: "gone",
              unpublished_at: Time.zone.now,
            },
          )
          described_class.call(edition, removal, user:)
          expect(request).to have_been_requested
        end
      end
    end

    context "when the edition does not have a removal" do
      it "sets the removed_at time" do
        freeze_time do
          removal = build(:removal)

          described_class.call(edition, removal, user:)
          expect(edition.status.details.removed_at).to eq(Time.zone.now)
        end
      end
    end

    context "when the edition already has a removal" do
      it "maintains the existing removed_at time" do
        existing_removed_at = 2.days.ago.noon
        existing_removal = build(:removal, removed_at: existing_removed_at)
        edition = create(:edition, :removed, removal: existing_removal)
        new_removal = build(:removal,
                            alternative_url: "/path",
                            explanatory_note: "explanation",
                            redirect: true)

        described_class.call(edition, new_removal, user:)
        expect(edition.status.details.removed_at).to eq(existing_removed_at)
      end
    end

    context "when Publishing API is down" do
      before { stub_publishing_api_isnt_available }

      it "doesn't change the editions state" do
        expect { described_class.call(edition, build(:removal), user:) }
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

        described_class.call(edition, build(:removal), user:)

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

        described_class.call(edition, build(:removal), user:)

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

        described_class.call(edition, build(:removal), user:)

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
        expect { described_class.call(draft_edition, build(:removal), user:) }
          .to raise_error "attempted to remove an edition other than the live edition"
      end
    end
  end
end
