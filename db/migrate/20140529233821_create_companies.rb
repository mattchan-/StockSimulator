class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :symbol

      t.timestamps
    end

    add_index :companies, :symbol, unique: true
  end
end
