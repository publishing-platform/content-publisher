class CreateImageRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :image_revisions do |t|
      t.references :image, null: false, foreign_key: { on_delete: :restrict }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.datetime :created_at, precision: nil, null: false
      t.references :blob_revision, null: false, foreign_key: { to_table: :image_blob_revisions, on_delete: :restrict }
      t.references :metadata_revision, null: false, foreign_key: { to_table: :image_metadata_revisions, on_delete: :restrict }
    end
  end
end
