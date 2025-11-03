require "rails_helper"

RSpec.describe DocumentTypeSelection::Option do
  describe "#managed_elsewhere?" do
    it "returns true if the option is managed_elsewhere" do
      option = {
        "id" => "foo",
        "type" => "managed_elsewhere",
      }

      expect(described_class.new(option).managed_elsewhere?).to be true
    end
  end

  describe "#managed_elsewhere_url" do
    it "returns the path if a hostname is not provided" do
      option = {
        "id" => "foo",
        "type" => "managed_elsewhere",
        "path" => "/bar",
      }

      expect(described_class.new(option).managed_elsewhere_url).to eq("/bar")
    end

    it "returns the full url if the hostname is provided" do
      host = PublishingPlatformLocation.external_url_for("example-host")

      option = {
        "id" => "foo",
        "type" => "managed_elsewhere",
        "hostname" => "example-host",
        "path" => "/bar",
      }

      expect(described_class.new(option).managed_elsewhere_url).to eq("#{host}/bar")
    end
  end

  describe "#document_type_selection?" do
    it "returns true when the option is a document_type_selection" do
      option = {
        "id" => "foo",
        "type" => "document_type_selection",
      }

      expect(described_class.new(option).document_type_selection?).to be true
    end
  end

  describe "#document_type?" do
    it "returns true when the option is a document_type" do
      option = {
        "id" => "foo",
        "type" => "document_type",
      }

      expect(described_class.new(option).document_type?).to be true
    end
  end
end
