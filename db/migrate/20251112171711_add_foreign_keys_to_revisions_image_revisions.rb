class AddForeignKeysToRevisionsImageRevisions < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :revisions_image_revisions, :revisions, on_delete: :cascade
    add_foreign_key :revisions_image_revisions, :image_revisions, on_delete: :restrict

    add_index :revisions_image_revisions, :revision_id
    add_index :revisions_image_revisions, :image_revision_id    
  end
end
