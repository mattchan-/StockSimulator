# == Schema Information
#
# Table name: company_data
#
#  id         :integer          not null, primary key
#  symbol     :string(255)
#  type       :string(255)
#  date       :date
#  value      :float
#  created_at :datetime
#  updated_at :datetime
#

class CompanyData < ActiveRecord::Base
  validates :symbol, :category, :date, :value, presence: true
end
