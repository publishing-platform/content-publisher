class AddLeadImageRevisionToRevisions < ActiveRecord::Migration[8.0]
  def change
    add_reference :revisions, :lead_image_revision, foreign_key: { to_table: :image_revisions, on_delete: :restrict }
  end
end
