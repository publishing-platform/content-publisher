class CreateJoinTableRevisionsFileAttachmentRevisions < ActiveRecord::Migration[8.0]
  def change
    create_join_table :revisions, :file_attachment_revisions, table_name: :revisions_file_attachment_revisions do |t|
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
