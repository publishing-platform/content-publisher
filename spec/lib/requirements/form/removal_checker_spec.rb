require "rails_helper"

RSpec.describe Requirements::Form::RemovalChecker do
  describe ".call" do
    let(:edition) { build(:edition) }

    it "returns no issues if there are none" do
      issues = described_class.call(edition, "")
      expect(issues).to be_empty
    end

    it "returns a redirect_url issue if the redirect_url is invalid" do
      issues = described_class.call(edition, "/test/&*")
      expect(issues).to have_issue(:redirect_url, :invalid)
    end
  end
end
