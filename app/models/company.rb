# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  symbol     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Company < ActiveRecord::Base
  before_create :upcase_symbol
  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true

  # HTTParty
  include HTTParty
  base_uri 'query.yahooapis.com'
  default_params format: "json", env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  debug_output $stderr

  # Checks if symbol exists in Company Database
  # If it does not exist, add to Company Database if it is a valid Yahoo Ticker Symbol
  def self.check(symbol)
    if Company.find_by(symbol: symbol)
      return true
    else
      query = "SELECT ErrorIndicationreturnedforsymbolchangedinvalid, Symbol, Name FROM yahoo.finance.quotes WHERE symbol in ('#{symbol}')"
      response = get '/v1/public/yql', query: { q: query }
      if response.success?
        response["query"]["results"].nil? ? (return false) : response = response["query"]["results"]["quote"]
        if response["ErrorIndicationreturnedforsymbolchangedinvalid"] == nil
          Company.create symbol: symbol, name: response["Name"]
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end

  def get_price
    query = "SELECT ErrorIndicationreturnedforsymbolchangedinvalid, LastTradePriceOnly FROM yahoo.finance.quotes WHERE symbol in ('#{symbol}')"
    response = self.class.get '/v1/public/yql', query: { q: query }
    if response.success?
      response["query"]["results"].nil? ? (return nil) : response = response["query"]["results"]["quote"]
      if response["ErrorIndicationreturnedforsymbolchangedinvalid"] == nil
        return response["LastTradePriceOnly"].to_f
      else
        return nil
      end
    else
      return nil
    end
  end

  private
    def upcase_symbol
      self[:symbol].upcase!
    end
end
