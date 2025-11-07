class CreateMetadataRevisions < ActiveRecord::Migration[8.0]
  def change
    create_table :metadata_revisions do |t|
      t.string :update_type, null: false
      t.text :change_note
      t.json :change_history, default: [], null: false
      t.string :document_type_id, null: false
      t.datetime :created_at, precision: nil, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
    end
  end
end
