class AddLastPriceUpdateToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :last_price_update, :date
  end
end
