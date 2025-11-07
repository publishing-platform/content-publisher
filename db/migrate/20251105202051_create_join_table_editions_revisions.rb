class CreateJoinTableEditionsRevisions < ActiveRecord::Migration[8.0]
  def change
    create_join_table :editions, :revisions do |t|
      t.index %i[edition_id revision_id]
      t.datetime :created_at, precision: nil, null: false
    end
  end
end
