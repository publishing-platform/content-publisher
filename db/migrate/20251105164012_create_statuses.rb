class CreateStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :statuses do |t|
      t.string :state, null: false

      t.references :revision_at_creation, null: false, foreign_key: { to_table: :revisions, on_delete: :restrict }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }

      t.timestamps
    end
  end
end
