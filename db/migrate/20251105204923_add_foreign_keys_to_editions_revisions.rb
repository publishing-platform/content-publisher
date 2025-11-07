class AddForeignKeysToEditionsRevisions < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :editions_revisions, :editions, on_delete: :cascade
    add_foreign_key :editions_revisions, :revisions, on_delete: :restrict

    add_index :editions_revisions, :edition_id
    add_index :editions_revisions, :revision_id
  end
end
