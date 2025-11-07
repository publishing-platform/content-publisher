require "rails_helper"

RSpec.describe Edition do
  describe ".find_current" do
    it "finds an edition by a document_id" do
      edition = create(:edition)
      param = edition.document.id.to_s

      expect(described_class.find_current(param)).to eq(edition)
    end

    it "only finds a current edition" do
      edition = create(:edition, current: false)

      expect { described_class.find_current(edition.document.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#add_edition_editor" do
    it "adds an edition user if they are not already listed as an editor" do
      user = build(:user)
      edition = build(:edition)

      edition.add_edition_editor(user)
      expect(edition.editors).to include(user)
    end

    it "does not add an edition user if they are already listed as an editor" do
      user = build(:user)
      edition = build(:edition, editors: [user])

      expect { edition.add_edition_editor(user) }
          .not_to(change { edition.editors })
    end
  end

  describe "#auth_bypass_token" do
    let(:edition) { create(:edition) }

    around { |example| freeze_time { example.run } }

    def decoded_token_payload(token)
      payload, _header = JWT.decode(
        token,
        Rails.application.credentials.jwt_auth_secret,
        true,
        { algorithm: "HS256" },
      )

      payload
    end

    it "returns a token with a sub of the auth_bypass_id" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["sub"]).to eq(edition.auth_bypass_id)
    end

    it "returns a token with the edition's content_id" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["content_id"]).to eq(edition.content_id)
    end

    it "returns a token issued at the current time" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["iat"]).to eq(Time.zone.now.to_i)
    end

    it "returns a token that expires in 1 month" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["exp"]).to eq(1.month.from_now.to_i)
    end
  end
end
