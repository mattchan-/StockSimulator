class AddPriceToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :price, :float
  end
end
