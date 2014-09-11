# == Schema Information
#
# Table name: companies
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  symbol            :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  price             :float
#  last_price_update :date
#

class Company < ActiveRecord::Base
  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true

  after_create :update_data

  # Checks if symbol exists in Company Database
  # If it does not exist, add to Company Database if it is a valid Yahoo Ticker Symbol
  def self.check(symbol)
    symbol = symbol.upcase
    company = Company.find_by(symbol: symbol)
    return company if company
    data = YQL.exists?(symbol)
    data ? Company.create(symbol: symbol, name: data[:name], price: data[:value], last_price_update: nil) : false
  end

  def update_data
    data = YQL.getAllData(symbol, last_price_update)
    return false unless data
    split_factor = 1
    data.each_with_index do |obj, idx|
      if obj[:category] == "split"
        split_factor *= obj[:value]
        data.delete_at idx
      end
    end
    if split_factor != 1
      CompanyData.where("symbol = ? AND date < ? AND category = ?", symbol, last_price_update, "close").each do |c|
        c.update value: (value / split_factor).round(4)
      end
    end
    data.each do |d|
      CompanyData.where(symbol: d[:symbol], category: d[:category], date: d[:date], value: d[:value].to_f.round(4)).first_or_create
    end
    self.update last_price_update: data.first[:date], price: data.first[:value]
    return true
  end

  def self.update_all_data
    Company.all.each do |c|
      c.update_data
    end
    Position.all.each do |p|
      p.get_price
    end
  end
end
