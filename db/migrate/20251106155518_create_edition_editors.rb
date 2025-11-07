class CreateEditionEditors < ActiveRecord::Migration[8.0]
  def change
    create_table :edition_editors do |t|
      t.datetime :created_at, precision: nil, null: false

      t.references :edition, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :restrict }

      t.index %i[edition_id user_id], unique: true
    end
  end
end
