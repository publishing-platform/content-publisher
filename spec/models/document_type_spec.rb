require "rails_helper"

RSpec.describe DocumentType do
  let(:document_types) { YAML.load_file(Rails.root.join("config/document_types.yml"), aliases: true)["document_types"] }

  describe "all configured document types are valid" do
    it "conforms to the document type schema" do
      expect(document_types).to all(match_json_schema("document_type"))
    end
  end

  describe ".all" do
    it "creates a DocumentType for each one in the YAML" do
      expect(described_class.all.count).to eq(document_types.count)
    end
  end

  describe ".find" do
    it "returns a DocumentType when it's a known document_type" do
      expect(described_class.find("press_release")).to be_a(described_class)
    end

    it "raises a RuntimeError when we don't know the document_type" do
      expect { described_class.find("unknown_document_type") }
        .to raise_error(RuntimeError, "Document type unknown_document_type not found")
    end
  end

  describe ".clear" do
    it "resets the DocumentType.all return value" do
      preexisting_doctypes = described_class.all.count
      build(:document_type)
      expect(described_class.all.count).to eq(preexisting_doctypes + 1)
      described_class.clear
      expect(described_class.all.count).to eq(preexisting_doctypes)
    end
  end
end
