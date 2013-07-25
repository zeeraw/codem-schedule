class AddLastAvailableAtToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :last_available_at, :datetime
    add_index  :hosts, :last_available_at
  end
end
