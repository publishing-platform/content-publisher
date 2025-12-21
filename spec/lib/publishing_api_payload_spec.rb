RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type)
      edition = build(:edition, document_type:)

      payload = described_class.new(edition).payload

      payload_hash = {
        document_type: document_type.id,
        publishing_app: "content-publisher",
        rendering_app: nil,
        schema_name: nil,
      }
      expect(payload).to match a_hash_including(payload_hash)
      expect(payload).not_to include(:first_published_at)
    end

    it "includes a public_updated_at timestamp for draft editions" do
      freeze_time do
        edition = build(:edition)

        payload = described_class.new(edition).payload

        payload_hash = {
          public_updated_at: Time.zone.now,
        }

        expect(payload).to match a_hash_including(payload_hash)
      end
    end

    it "includes a first_published_at and public_updated_at timestamp for published editions" do
      edition = build(:edition, :published, first_published_at: "2020-02-20 08:00:00")

      payload = described_class.new(edition).payload

      payload_hash = {
        first_published_at: Time.zone.parse("2020-02-20 08:00:00"),
        public_updated_at: Time.zone.parse("2020-02-20 08:00:00"),
      }

      expect(payload).to match a_hash_including(payload_hash)
    end

    it "delegates to PublishingApiPayload::History to populate change_history" do
      history = instance_double(
        PublishingApiPayload::History,
        change_history: [{ note: "note", public_timestamp: Time.zone.now }],
        public_updated_at: Time.zone.now,
        first_published_at: Time.zone.now,
      )
      allow(PublishingApiPayload::History).to receive(:new).and_return(history)

      payload = described_class.new(build(:edition)).payload

      expect(payload[:details][:change_history]).to match(history.change_history)
    end

    it "delegates to PublishingApiPayload::FileAttachmentPayload to populate attachments" do
      file_attachment_revision = create(:file_attachment_revision)
      edition = build(:edition,
                      document: create(:document),
                      file_attachment_revisions: [file_attachment_revision])

      payload = described_class.new(edition).payload
      attachment_payload = PublishingApiPayload::FileAttachmentPayload
                             .new(file_attachment_revision, edition)
                             .payload

      expect(payload[:details][:attachments]).to contain_exactly(attachment_payload)
    end

    it "specifies an auth bypass ID for anonymous previews" do
      edition = build(:edition)
      payload = described_class.new(edition).payload
      expect(payload[:auth_bypass_ids]).to eq([edition.auth_bypass_id])
    end

    it "delegates to document type fields for tags" do
      tag_field = instance_double(DocumentType::PrimaryPublishingOrganisationField,
                                  payload: { links: { foo: %w[bar] } })
      document_type = build(:document_type, tags: [tag_field])
      edition = build(:edition,
                      document_type:,
                      tags: { foo: %w[bar] })

      payload = described_class.new(edition).payload
      expect(payload[:links]).to match a_hash_including(foo: %w[bar])
    end

    it "delegates to document type fields for contents" do
      body_field = instance_double(DocumentType::BodyField,
                                   payload: { details: { body: "body" } })

      document_type = build(:document_type, contents: [body_field])
      edition = build(:edition, document_type:)
      payload = described_class.new(edition).payload
      expect(payload[:details][:body]).to eq("body")
    end

    it "includes a lead image if present" do
      image_revision = build(:image_revision,
                             :on_asset_manager,
                             alt_text: "image alt text",
                             caption: "image caption",
                             credit: "image credit")

      document_type = build(:document_type, :with_lead_image)

      edition = build(:edition,
                      document_type:,
                      lead_image_revision: image_revision)

      payload = described_class.new(edition).payload

      payload_hash = {
        url: image_revision.asset_url("300"),
        high_resolution_url: image_revision.asset_url("high_resolution"),
        alt_text: "image alt text",
        caption: "image caption",
        credit: "image credit",
      }

      expect(payload[:details][:image]).to match a_hash_including(payload_hash)
    end

    it "doesn't present nil image attributes" do
      image_revision = build(:image_revision,
                             :on_asset_manager,
                             alt_text: nil,
                             caption: "")

      document_type = build(:document_type, :with_lead_image)

      edition = build(:edition,
                      document_type:,
                      lead_image_revision: image_revision)

      payload = described_class.new(edition).payload

      payload_hash = {
        url: image_revision.asset_url("300"),
        high_resolution_url: image_revision.asset_url("high_resolution"),
        caption: "",
      }

      expect(payload[:details][:image]).to eq(payload_hash)
    end

    it "includes ordered featured attachments if document type supports them" do
      file_attachment1 = create(:file_attachment_revision)
      file_attachment2 = create(:file_attachment_revision)
      file_attachment3 = create(:file_attachment_revision)
      attachments = [file_attachment1, file_attachment2, file_attachment3]
      ordering = [file_attachment2, file_attachment3].map(&:file_attachment_id).reverse

      document_type = build :document_type, attachments: "featured"
      edition = build(:edition,
                      document: create(:document),
                      document_type:,
                      file_attachment_revisions: attachments,
                      featured_attachment_ordering: ordering)

      payload = described_class.new(edition).payload

      expect(payload[:details][:featured_attachments]).to eq(attachments.map(&:file_attachment_id).reverse)
    end

    it "doesn't include ordered featured attachments if document type does not support them" do
      file_attachment1 = create(:file_attachment_revision)
      file_attachment2 = create(:file_attachment_revision)
      file_attachment3 = create(:file_attachment_revision)
      attachments = [file_attachment1, file_attachment2, file_attachment3]
      ordering = [file_attachment2, file_attachment3].map(&:file_attachment_id).reverse

      edition = build(:edition,
                      document: create(:document),
                      file_attachment_revisions: attachments,
                      featured_attachment_ordering: ordering)

      payload = described_class.new(edition).payload

      expect(payload).to match a_hash_including(details: hash_excluding(:featured_attachments))
    end
  end
end
