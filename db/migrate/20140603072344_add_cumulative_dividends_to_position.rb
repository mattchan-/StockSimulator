class AddCumulativeDividendsToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :cumulative_dividends, :float
  end
end
