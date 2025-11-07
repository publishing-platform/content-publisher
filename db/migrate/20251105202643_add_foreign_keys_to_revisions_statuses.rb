class AddForeignKeysToRevisionsStatuses < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :revisions_statuses, :revisions, on_delete: :restrict
    add_foreign_key :revisions_statuses, :statuses, on_delete: :cascade

    add_index :revisions_statuses, :revision_id
    add_index :revisions_statuses, :status_id
  end
end
