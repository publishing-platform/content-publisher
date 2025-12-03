class CreateFileAttachmentBlobRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :file_attachment_blob_revisions do |t|
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs, on_delete: :restrict }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.datetime :created_at, precision: nil, null: false
      t.string :filename, null: false
      t.integer :number_of_pages
    end
  end
end
