class CreateRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :revisions do |t|
      t.integer :number, null: false
      t.datetime :created_at, precision: nil, null: false

      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :document, null: false, foreign_key: { on_delete: :restrict }
      t.references :content_revision, null: false, foreign_key: { on_delete: :restrict }
      t.references :metadata_revision, null: false, foreign_key: { on_delete: :restrict }
      t.references :tags_revision, null: false, foreign_key: { on_delete: :restrict }
      t.references :preceded_by, foreign_key: { to_table: :revisions, on_delete: :restrict }

      t.index %i[number document_id], unique: true
    end
  end
end
