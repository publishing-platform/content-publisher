require "rails_helper"

RSpec.describe "Resync tasks" do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  describe "resync:document" do
    it "resyncs a document" do
      document = create(:document)

      expect(ResyncDocumentService)
        .to receive(:call)
        .once
        .with(document)

      Rake::Task["resync:document"].invoke(document.content_id.to_s)
    end
  end

  describe "resync:all" do
    it "resyncs all documents" do
      create_list(:document, 2)

      expect(ResyncDocumentJob)
        .to receive(:perform_later)
        .twice

      Rake::Task["resync:all"].invoke
    end
  end
end
