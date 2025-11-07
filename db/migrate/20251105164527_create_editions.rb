class CreateEditions < ActiveRecord::Migration[8.0]
  def change
    create_table :editions do |t|
      t.integer :number, null: false
      t.datetime :last_edited_at, precision: nil, null: false
      t.boolean :revision_synced, default: false, null: false
      t.datetime :published_at, precision: nil
      t.uuid :auth_bypass_id, null: false
      t.boolean :current, default: false, null: false
      t.boolean :live, default: false, null: false

      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :last_edited_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :document, null: false, foreign_key: { on_delete: :restrict }
      t.references :status, null: false, foreign_key: { on_delete: :restrict }
      t.references :revision, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end
  end
end
