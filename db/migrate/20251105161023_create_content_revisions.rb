class CreateContentRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :content_revisions do |t|
      t.string :title
      t.string :base_path
      t.text :summary
      t.json :contents, default: {}, null: false
      t.datetime :created_at, precision: nil, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
    end
  end
end
