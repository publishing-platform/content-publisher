class AddEditionReferenceToStatuses < ActiveRecord::Migration[8.0]
  def change
    add_reference :statuses, :edition, foreign_key: { on_delete: :cascade }
  end
end
