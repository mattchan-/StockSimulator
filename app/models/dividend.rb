# == Schema Information
#
# Table name: dividends
#
#  id               :integer          not null, primary key
#  symbol           :string(255)
#  dividends        :float
#  ex_dividend_date :date
#  created_at       :datetime
#  updated_at       :datetime
#  company_id       :integer
#

class Dividend < ActiveRecord::Base
  validates :symbol, presence: true
  validates :dividends, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :company_id, presence: true, numericality: { greater_than: 0 }
  validates :ex_dividend_date, presence: true

  belongs_to :company

  def self.update(symbol)
    data = YQL.dividends(symbol)
    company_id = Company.find_by(symbol: symbol).id
    return false unless data
    data = [data] unless data.kind_of?(Array)
    data.each do |d|
      record = Dividend.where(symbol: symbol).find_by(ex_dividend_date: d["Date"])
      record ? record.update_attributes(dividends: d["Dividends"], company_id: company_id) : Dividend.create(symbol: symbol, dividends: d["Dividends"], ex_dividend_date: d["Date"], company_id: company_id)
    end
  end
end
