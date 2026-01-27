require "rails_helper"

RSpec.describe Requirements::Form::RemovalChecker do
  describe ".call" do
    let(:edition) { build(:edition) }

    it "returns no issues if there are none" do
      valid_redirect_urls = [
        "",
        "/validredirect",
        "/valid-redirect",
        "/path/another-valid-redirect",
      ]
      valid_redirect_urls.each do |redirect_url|
        issues = described_class.call(edition, redirect_url)
        expect(issues).to be_empty
      end
    end

    it "returns a redirect_url issue if the redirect_url is invalid" do
      invalid_redirect_urls = [
        "&*",
        "/invalid/&*",
        "//invalid",
        "/invalid redirect",
        "/invalid_redirect",
        "/invalid?query=string",
      ]
      invalid_redirect_urls.each do |redirect_url|
        issues = described_class.call(edition, redirect_url)
        expect(issues).to have_issue(:redirect_url, :invalid)
      end
    end
  end
end
