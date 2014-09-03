class CreateCompanyData < ActiveRecord::Migration
  def change
    create_table :company_data do |t|
      t.string :symbol
      t.string :category
      t.date :date
      t.float :value

      t.timestamps
    end
    add_index :company_data, :symbol
    add_index :company_data, :date
  end
end
