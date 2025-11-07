class CreateTagsRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :tags_revisions do |t|
      t.json :tags, default: {}, null: false
      t.datetime :created_at, precision: nil, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
    end
  end
end
