class AddCashToPortfolio < ActiveRecord::Migration
  def change
    add_column :portfolios, :cash, :float
  end
end
