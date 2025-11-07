RSpec.describe EditionFilter do
  let(:user) { build :user, organisation_content_id: SecureRandom.uuid }

  describe "#editions" do
    it "orders the editions by edition last_edited_at" do
      edition1 = create(:edition, last_edited_at: 2.minutes.ago)
      edition2 = create(:edition, last_edited_at: 3.minutes.ago)
      edition3 = create(:edition, last_edited_at: 5.minutes.ago)
      edition4 = create(:edition, last_edited_at: 1.minute.ago)

      editions = described_class.new.editions
      expect(editions).to eq([edition4, edition1, edition2, edition3])
    end

    it "filters the editions by title or URL" do
      edition1 = create(:edition, title: "First", base_path: "/doc_1")
      edition2 = create(:edition, title: "Second", base_path: "/doc_2")

      editions = described_class.new(filters: { title_or_url: " " }).editions
      expect(editions).to contain_exactly(edition1, edition2)

      editions = described_class.new(filters: { title_or_url: "Fir" }).editions
      expect(editions).to eq([edition1])

      editions = described_class.new(filters: { title_or_url: "_1" }).editions
      expect(editions).to eq([edition1])

      editions = described_class.new(filters: { title_or_url: "%" }).editions
      expect(editions).to be_empty
    end

    it "filters the editions by type" do
      edition1 = create(:edition, document_type_id: "type_1")
      edition2 = create(:edition, document_type_id: "type_2")

      editions = described_class.new(filters: { document_type: " " }).editions
      expect(editions).to contain_exactly(edition1, edition2)

      editions = described_class.new(filters: { document_type: "type_1" }).editions
      expect(editions).to eq([edition1])
    end

    it "filters the editions by status" do
      edition1 = create(:edition, state: "draft")
      edition2 = create(:edition, state: "submitted_for_review")

      editions = described_class.new(filters: { status: " " }).editions
      expect(editions).to contain_exactly(edition1, edition2)

      editions = described_class.new(filters: { status: "non-existant" }).editions
      expect(editions).to be_empty

      editions = described_class.new(filters: { status: "draft" }).editions
      expect(editions).to eq([edition1])
    end

    it "includes published_but_needs_2i in published status filter" do
      edition1 = create(:edition, state: "published")
      edition2 = create(:edition, state: "published_but_needs_2i")

      editions = described_class.new(filters: { status: "published" }).editions
      expect(editions).to contain_exactly(edition1, edition2)

      editions = described_class.new(filters: { status: "published_but_needs_2i" }).editions
      expect(editions).to eq([edition2])
    end

    it "filters the editions by organisation" do
      org_id1 = SecureRandom.uuid
      org_id2 = SecureRandom.uuid

      edition1 = create(:edition, tags: { primary_publishing_organisation: [org_id1] })
      edition2 = create(:edition, tags: { primary_publishing_organisation: [org_id1] })
      edition3 = create(:edition, tags: { primary_publishing_organisation: [org_id2] })

      editions = described_class.new(filters: { organisation: " " }).editions
      expect(editions).to contain_exactly(edition1, edition2, edition3)

      editions = described_class.new(filters: { organisation: org_id1 }).editions
      expect(editions).to contain_exactly(edition1, edition2)
    end

    it "ignores other kinds of filter" do
      edition1 = create(:edition)

      editions = described_class.new(filters: { invalid: "filter" }).editions
      expect(editions).to eq([edition1])
    end
  end

  describe "#filter_params" do
    it "returns the params used to filter" do
      params = described_class.new(filters: { title_or_url: "title" }).filter_params
      expect(params).to eq(title_or_url: "title")
    end

    it "maintains empty params" do
      params = described_class.new(filters: { organisation: "" }).filter_params
      expect(params).to eq(organisation: "")
    end
  end
end
