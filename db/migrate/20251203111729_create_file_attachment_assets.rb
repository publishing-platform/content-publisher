class CreateFileAttachmentAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :file_attachment_assets do |t|
      t.references :blob_revision, null: false, foreign_key: { to_table: :file_attachment_blob_revisions, on_delete: :cascade }, index: { unique: true }
      t.references :superseded_by, foreign_key: { to_table: :file_attachment_assets, on_delete: :nullify }
      t.string :file_url
      t.string :state, default: "absent", null: false

      t.timestamps

      t.index :file_url, unique: true
    end
  end
end
