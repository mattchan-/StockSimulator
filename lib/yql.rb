require 'rubygems'
require 'httparty'

class YQL
  include HTTParty
  base_uri 'query.yahooapis.com/'
  default_params format: "json", env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  # returns a hash of stock data unless an error occurs
  def self.quote(symbol)
    query = "SELECT ErrorIndicationreturnedforsymbolchangedinvalid, Symbol, Name, LastTradePriceOnly, Change, EarningsShare FROM yahoo.finance.quotes WHERE symbol in ('#{symbol}')"
    response = get '/v1/public/yql', query: { q: query }

    return false unless response.success?
    return false if response["query"]["results"].nil?
    return false if response["query"]["results"]["quote"]["ErrorIndicationreturnedforsymbolchangedinvalid"] != nil
    return response["query"]["results"]["quote"]
  end

  # symbols is an array of symbols
  def self.quotes(symbols)
    symbols = symbols.reject(&:nil?).join("','")
    query = "SELECT ErrorIndicationreturnedforsymbolchangedinvalid, Symbol, Name, LastTradePriceOnly, Change, EarningsShare FROM yahoo.finance.quotes WHERE symbol in ('#{symbols}')"
    response = get '/v1/public/yql', query: { q: query }
    return false unless response.success?
    return false if response["query"]["results"].nil?
    return response["query"]["results"]["quote"]
  end

  #
  def self.dividends(symbol)
    query = "use 'store://bg2cgClQyQC1c5gJE3UXUn' as yahoo.finance.dividendhistory; select * from yahoo.finance.dividendhistory where symbol = '" + symbol + "' and startDate = '1990-01-01' and endDate = '" + Date.today.strftime("%Y-%m-%d") + "'"
    response = get '/v1/public/yql', query: { q: query }
    return false unless response.success?
    return false if response["query"]["results"].nil?
    return response["query"]["results"]["quote"]
  end

  def self.historicalClose(symbol, date)
    date = date.strftime("%Y-%m-%d")
    query = "SELECT Close FROM yahoo.finance.historicaldata WHERE symbol = '#{symbol}' and startDate = '#{date}' and endDate = '#{date}'"
    puts query
    response = get '/v1/public/yql', query: { q: query }
    puts response
    return false unless response.success?
    return false if response["query"]["results"].nil?
    return response["query"]["results"]["quote"]["Close"].to_f
  end
end