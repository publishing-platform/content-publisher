class CreateFileAttachmentMetadataRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :file_attachment_metadata_revisions do |t|
      t.string :title, null: false
      t.string :isbn
      t.string :unique_reference
      t.string :paper_number
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
