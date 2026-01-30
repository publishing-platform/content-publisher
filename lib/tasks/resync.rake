namespace :resync do
  desc "Resync a document with the publishing-api e.g. resync:document['a-content-id']"
  task :document, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    document = Document.find_by(content_id: args.content_id)

    raise "No document exists for #{args.content_id}" unless document

    ResyncDocumentService.call(document)
  end

  desc "Resync all documents with the publishing-api e.g. resync:all"
  task all: :environment do
    Document.find_each do |document|
      ResyncDocumentJob.perform_later(document)
    end
  end
end
