require "rails_helper"

RSpec.describe "Remove", type: :request do
  # let(:user) { create(:user) }

  it_behaves_like "requests that assert edition state",
                  "removing a draft edition",
                  routes: { remove_path: %i[get post] } do
    # before { login_as(user) }

    let(:edition) { create(:edition) }
  end

  describe "POST /documents/:document_id/remove" do
    let(:edition) { create(:edition, :published) }

    before do
      stub_publishing_api_unpublish(edition.content_id, body: {})
    end

    it "allows removing an edition" do
      post remove_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
    end

    it "returns a service unavailable response with error when Publishing API is unavailable" do
      stub_publishing_api_isnt_available

      post remove_path(edition.document)
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to have_content(
        I18n.t!("remove.new.flashes.publishing_api_error"),
      )
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      post remove_path(edition.document),
           params: { redirect_url: "invalid" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to have_content(
        I18n.t!("requirements.redirect_url.invalid.form_message"),
      )
    end
  end

  describe "GET /documents/:document_id/remove" do
    it "allows removing a published edition" do
      edition = create(:edition, :published)
      get remove_path(edition.document)
      expect(response).to have_http_status(:ok)
    end

    it "allows removing a published but needs 2i edition" do
      edition = create(:edition, :published, state: :published_but_needs_2i)
      get remove_path(edition.document)
      expect(response).to have_http_status(:ok)
    end
  end
end
