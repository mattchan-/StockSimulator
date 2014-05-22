class AddDateAcquiredToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :date_acquired, :date
  end
end
