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
  before_create :upcase_symbol, :update_price
  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true

  # Checks if symbol exists in Company Database
  # If it does not exist, add to Company Database if it is a valid Yahoo Ticker Symbol
  def self.check(symbol)
    return true if Company.find_by(symbol: symbol)
    data = YQL.check(symbol)
    Company.create symbol: symbol, name: data["Name"], price: data["LastTradePriceOnly"] if data
  end

  def update_price
    data = YQL.check(symbol)
    update_attributes price: data["LastTradePriceOnly"] if data
  end

  def self.update_all_prices
    Company.pluck(:symbol).in_groups_of(400) do |group|
      data = YQL.quotes(group)
      return false unless data
      data.each_with_index do |d, index|
        Company.find_by(symbol: group[index]).update_attributes(
          price: d["LastTradePriceOnly"],
          symbol: d["Symbol"]
        )
      end
    end
    true
  end

  private
    def upcase_symbol
      self[:symbol].upcase!
    end
end
