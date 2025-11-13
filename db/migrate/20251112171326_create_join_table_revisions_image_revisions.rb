class CreateJoinTableRevisionsImageRevisions < ActiveRecord::Migration[8.0]
  def change
    create_join_table :revisions, :image_revisions, table_name: :revisions_image_revisions do |t|
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
