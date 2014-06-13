class AddCompanyIdToDividend < ActiveRecord::Migration
  def change
    add_column :dividends, :company_id, :integer
  end
end
