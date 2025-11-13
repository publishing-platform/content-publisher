class CreateImageBlobRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :image_blob_revisions do |t|
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs, on_delete: :restrict }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.datetime :created_at, precision: nil, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :crop_x, null: false
      t.integer :crop_y, null: false
      t.integer :crop_width, null: false
      t.integer :crop_height, null: false
      t.string :filename, null: false
    end
  end
end
