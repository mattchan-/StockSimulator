require 'rubygems'
require 'httparty'

class YQL
  include HTTParty
  base_uri 'query.yahooapis.com/'
  default_params format: "json", env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  # returns nil if symbol 
  def self.quote(symbol)
    query = "SELECT ErrorIndicationreturnedforsymbolchangedinvalid, Symbol, Name, LastTradePriceOnly, Change, EarningsShare FROM yahoo.finance.quotes WHERE symbol in ('#{symbol}')"
    response = get '/v1/public/yql', query: { q: query }

    return false unless response.success?
    return false if response["query"]["results"].nil?
    return false if response["query"]["results"]["quote"]["ErrorIndicationreturnedforsymbolchangedinvalid"] != nil
    return response["query"]["results"]["quote"].except "ErrorIndicationreturnedforsymbolchangedinvalid"
  end

  # symbols should be an array of symbols
  def self.quotes(symbols)
    symbols = symbols.reject(&:nil?).join("','")
    query = "SELECT ErrorIndicationreturnedforsymbolchangedinvalid, Symbol, Name, LastTradePriceOnly, Change, EarningsShare FROM yahoo.finance.quotes WHERE symbol in ('#{symbols}')"
    response = get '/v1/public/yql', query: { q: query }
    return false unless response.success?
    return false if response["query"]["results"].nil?
    return response["query"]["results"]["quote"]
  end
end