class CreateJoinTableRevisionsStatuses < ActiveRecord::Migration[8.0]
  def change
    create_join_table :revisions, :statuses do |t|
      t.index %i[revision_id status_id]
      t.index %i[status_id revision_id]
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
