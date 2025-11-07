class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.uuid :content_id, null: false
      t.datetime :first_published_at, precision: nil
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }

      t.timestamps

      t.index :content_id, unique: true
    end
  end
end
