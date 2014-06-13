# == Schema Information
#
# Table name: dividends
#
#  id               :integer          not null, primary key
#  symbol           :string(255)
#  dividends        :float
#  ex_dividend_date :float
#  created_at       :datetime
#  updated_at       :datetime
#

class Dividend < ActiveRecord::Base
  validates :symbol, presence: true
  validates :dividends, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ex_dividend_date, presence: true

  def self.update(symbol)
    data = YQL.dividends(symbol)
    return false unless data
    data = [data] unless data.kind_of?(Array)
    data.each do |d|
      record = Dividend.where(symbol: symbol).find_by(ex_dividend_date: d["Date"])
      record ? record.update_attributes(dividends: d["Dividends"]) : Dividend.create(symbol: symbol, dividends: d["Dividends"], ex_dividend_date: d["Date"])
    end
  end
end
