require "rails_helper"

RSpec.describe "Documents", type: :request do
  it_behaves_like "requests that assert edition state",
                  "modifying a non editable edition",
                  routes: { content_path: %i[patch get],
                            generate_path_path: %i[get] } do
    let(:edition) { create(:edition, :published) }
  end

  describe "GET /documents" do
    let(:organisation_content_id) { SecureRandom.uuid }
    let(:user) { create(:user, organisation_content_id:) }

    before do
      login_as(user)
      stub_publishing_api_has_linkables([], document_type: "organisation")
    end

    context "when filter parameters are provided" do
      it "returns successfully" do
        get documents_path(organisation: "")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user has an organisation" do
      it "redirects to filter by the users organisation" do
        get documents_path
        expect(response).to redirect_to(
          documents_path(organisation: organisation_content_id),
        )
      end
    end

    context "when the user doesn't have an organisation" do
      let(:user) { create(:user, organisation_content_id: nil) }

      before { login_as(user) }

      it "returns successfully" do
        get documents_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /documents/new" do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    it "shows the root document type selection when no selection has been made" do
      get new_document_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(I18n.t("document_type_selections.root.label"))
    end

    it "shows the page for the selected document type" do
      get new_document_path, params: { type: "news" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(I18n.t("document_type_selections.news.label"))
    end

    it "returns a 404 when the requested document type selection doesn't exist" do
      get new_document_path, params: { type: "foo" }
      expect(response.status).to eq(404)
    end
  end

  describe "POST /documents" do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    it "redirects to document edit content when a content publisher managed document type is selected" do
      post documents_path, params: { type: "news", selected_option_id: "news_story" }

      expect(response).to redirect_to(content_path(Document.last))
      follow_redirect!
      expect(response.body).to match("news story")
    end

    it "asks the user to refine their selection when the document type has subtypes" do
      post documents_path, params: { type: "root", selected_option_id: "news" }

      expect(response).to redirect_to(new_document_path(type: "news"))
      follow_redirect!
      expect(response.body).to match(I18n.t("document_type_selections.news_story.label"))
    end

    it "returns an unprocessable response with an issue when a document type isn't selected" do
      post documents_path, params: { type: "news" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to match(
        I18n.t("requirements.document_type_selection.not_selected.form_message"),
      )
    end

    it "returns a 404 when the requested selected document type doesn't exist" do
      post documents_path, params: { type: "foo", selected_option_id: "foo" }
      expect(response.status).to eq(404)
    end
  end

  describe "GET /documents/:document/generate-path" do
    it "returns a text response of a path" do
      edition = create(:edition, title: "A title")
      prefix = edition.document_type.path_prefix
      get generate_path_path(edition.document, title: "A title")

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to match("#{prefix}/a-title")
    end
  end
end
