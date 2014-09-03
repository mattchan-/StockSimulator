# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  symbol     :string(255)
#  created_at :datetime
#  updated_at :datetime
#  price      :float
#

class Company < ActiveRecord::Base
  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :dividends, dependent: :destroy

  # Checks if symbol exists in Company Database
  # If it does not exist, add to Company Database if it is a valid Yahoo Ticker Symbol
  def self.check(symbol)
    symbol = symbol.upcase
    company = Company.find_by(symbol: symbol)
    return company if company
    data = YQL.quote(symbol)
    data ? Company.create(symbol: symbol, name: data["Name"], price: data["LastTradePriceOnly"]) : false
  end

  def update_price
    data = YQL.quote(symbol)
    update price: data["LastTradePriceOnly"] if data
  end

  # broken
  def self.update_all_prices
    Company.pluck(:symbol).in_groups_of(20) do |group|
      data = YQL.quotes(group)
      return false unless data
      data.each_with_index do |d, index|
        Company.find_by(symbol: group[index]).update!(price: d["LastTradePriceOnly"])
      end
    end
    true
  end
end
