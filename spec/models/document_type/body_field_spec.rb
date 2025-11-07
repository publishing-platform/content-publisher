require "rails_helper"

RSpec.describe DocumentType::BodyField do
  describe "#payload" do
    it "returns a 'body' array containing markdown content type" do
      edition = build(:edition, contents: { body: "Hey **buddy**!" })
      payload = described_class.new.payload(edition)
      expect(payload[:details][:body][0][:content_type]).to eq("text/markdown")
      expect(payload[:details][:body][0][:content]).to eq("Hey **buddy**!")
    end
  end

  describe "#updater_params" do
    it "returns a hash of the body" do
      edition = build :edition
      params = ActionController::Parameters.new(body: "body")
      updater_params = described_class.new.updater_params(edition, params)
      expect(updater_params).to eq(contents: { body: "body" })
    end
  end

  describe "#form_issues" do
    let(:edition) { build :edition }

    it "returns no issues" do
      issues = described_class.new.form_issues(edition, nil)
      expect(issues).to be_empty
    end
  end

  describe "#preview_issues" do
    it "returns no issues" do
      edition = build :edition, contents: { body: "body" }
      issues = described_class.new.preview_issues(edition)
      expect(issues).to be_empty
    end
  end

  describe "#publish_issues" do
    it "returns no issues when there are none" do
      edition = build :edition, contents: { body: "alert('hi')" }
      issues = described_class.new.publish_issues(edition)
      expect(issues).to be_empty
    end

    it "returns an issue when the body is empty" do
      edition = build :edition, contents: { body: " " }
      issues = described_class.new.publish_issues(edition)
      expect(issues).to have_issue(:body, :blank, styles: %i[summary])
    end
  end
end
