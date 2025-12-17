class AddFeaturedAttachmentOrderingToMetadataRevisions < ActiveRecord::Migration[8.0]
  def change
    add_column :metadata_revisions, :featured_attachment_ordering, :bigint, default: [], null: false, array: true
  end
end
