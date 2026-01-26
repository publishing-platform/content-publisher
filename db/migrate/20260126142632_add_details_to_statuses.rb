class AddDetailsToStatuses < ActiveRecord::Migration[8.0]
  def change
    add_reference :statuses, :details, polymorphic: true
  end
end
