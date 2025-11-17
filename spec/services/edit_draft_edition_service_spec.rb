RSpec.describe EditDraftEditionService do
  describe ".call" do
    let(:edition) { build(:edition, revision_synced: true) }
    let(:user) { build(:user) }

    it "assigns attributes to an edition" do
      revision = build(:revision)

      expect { described_class.call(edition, user, revision:) }
        .to change(edition, :revision).to(revision)
    end

    it "does not save the edition" do
      described_class.call(edition, user, **{})

      expect(edition).to be_new_record
    end

    it "updates who edited it and when" do
      freeze_time do
        edition = build(:edition, last_edited_at: 3.weeks.ago)

        expect { described_class.call(edition, user) }
          .to change { edition.last_edited_by }.to(user)
          .and change { edition.last_edited_at }.to(Time.zone.now)
      end
    end

    it "raises an error if a live edition is edited" do
      live_edition = build(:edition, live: true)

      expect { described_class.call(live_edition, user) }
        .to raise_error("cannot edit a live edition")
    end

    describe "updates the edition editors" do
      it "adds an edition user if they are not already listed as an editor" do
        edition = build(:edition)

        expect { described_class.call(edition, user) }
          .to change { edition.editors.size }
          .by(1)
      end
    end

    describe "updates revision sync flag" do
      it "flags the revision as out-of-sync if updated" do
        revision = build(:revision)

        expect { described_class.call(edition, user, revision:) }
          .to change(edition, :revision_synced).to(false)
      end

      it "preserves revision sync flag if it's not updated" do
        expect { described_class.call(edition, user) }
          .not_to change(edition, :revision_synced)
      end
    end
  end
end
