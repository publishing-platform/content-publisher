class CreateRemovals < ActiveRecord::Migration[8.0]
  def change
    create_table :removals do |t|
      t.string :explanatory_note
      t.string :alternative_url
      t.boolean :redirect, default: false
      t.datetime :created_at, precision: nil, null: false
      t.datetime :removed_at, precision: nil, null: false
    end
  end
end
