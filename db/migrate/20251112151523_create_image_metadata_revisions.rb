class CreateImageMetadataRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :image_metadata_revisions do |t|
      t.string :caption
      t.string :alt_text
      t.string :credit
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
