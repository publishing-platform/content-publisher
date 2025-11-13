require "rails_helper"

RSpec.describe CreateDocumentService do
  let(:user) { create(:user) }

  describe ".call" do
    let(:document_type) { build(:document_type) }

    it "creates a document" do
      expect { described_class.call(document_type_id: document_type.id, user:) }
        .to change(Document, :count).by(1)
    end

    it "runs inside a transaction so failures are rolled back" do
      expect(Document).to receive(:transaction)
      described_class.call(document_type_id: document_type.id, user:)
    end

    it "sets the document to have a draft current edition for the appropriate document type" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition).to be_draft
      expect(document.current_edition.document_type).to eq(document_type)
    end

    it "sets the numbers of the first edition and first revision accordingly" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition.number).to be(1)
      expect(document.current_edition.revision.number).to be(1)
    end

    it "sets the initial update type" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition.update_type).to eq("major")
    end

    it "associates the current edition revision with the document" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition.revision.document).to eq(document)
    end

    it "associates the current edition status with the corresponding revision" do
      document = described_class.call(document_type_id: document_type.id, user:)
      revision = document.current_edition.revision
      status = document.current_edition.status
      expect(status.revision_at_creation).to eq(revision)
    end

    it "can have content_id specified" do
      content_id = SecureRandom.uuid
      document = described_class.call(content_id:,
                                      document_type_id: document_type.id,
                                      user:)

      expect(document.content_id).to eq(content_id)
    end

    it "is attributed to a user" do
      document = described_class.call(document_type_id: document_type.id,
                                      user:)

      expect(document.created_by).to eq(user)
      expect(document.current_edition.created_by).to eq(user)
      expect(document.current_edition.last_edited_by).to eq(user)
      expect(document.current_edition.status.created_by).to eq(user)

      revision = document.current_edition.revision
      expect(revision.created_by).to eq(user)
      expect(revision.content_revision.created_by).to eq(user)
      expect(revision.metadata_revision.created_by).to eq(user)
      expect(revision.tags_revision.created_by).to eq(user)
    end

    it "fails if no user provided" do
      expect {
        described_class.call(document_type_id: document_type.id,
                             user: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "can set tags on the current edition" do
      tags = { "primary_publishing_organisation" => [SecureRandom.uuid] }
      document = described_class.call(document_type_id: document_type.id,
                                      user:,
                                      tags:)

      expect(document.current_edition.tags).to eq(tags)
    end
  end
end
