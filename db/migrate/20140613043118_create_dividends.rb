class CreateDividends < ActiveRecord::Migration
  def change
    create_table :dividends do |t|
      t.string :symbol
      t.float :dividends
      t.float :ex_dividend_date

      t.timestamps
    end
  end
end
