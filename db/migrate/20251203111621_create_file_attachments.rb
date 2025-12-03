class CreateFileAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :file_attachments do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
