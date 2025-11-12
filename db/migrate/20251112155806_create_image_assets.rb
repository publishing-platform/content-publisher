class CreateImageAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :image_assets do |t|
      t.references :blob_revision, null: false, foreign_key: { to_table: :image_blob_revisions, on_delete: :cascade }
      t.references :superseded_by, foreign_key: { to_table: :image_assets,  on_delete: :nullify }
      t.string :variant, null: false
      t.string :file_url
      t.string :state, default: "absent", null: false

      t.timestamps

      t.index [:blob_revision_id, :variant], unique: true
      t.index :file_url, unique: true
    end
  end
end
