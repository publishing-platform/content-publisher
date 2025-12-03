class AddForeignKeysToRevisionsFileAttachmentRevisions < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :revisions_file_attachment_revisions, :revisions, on_delete: :cascade
    add_foreign_key :revisions_file_attachment_revisions, :file_attachment_revisions, on_delete: :restrict

    add_index :revisions_file_attachment_revisions, :revision_id
    add_index :revisions_file_attachment_revisions, :file_attachment_revision_id
  end
end
