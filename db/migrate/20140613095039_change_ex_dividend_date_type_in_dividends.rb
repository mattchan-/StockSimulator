class ChangeExDividendDateTypeInDividends < ActiveRecord::Migration
  def change
    change_column :dividends, :ex_dividend_date, :date
  end
end
