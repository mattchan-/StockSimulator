require 'rubygems'
require 'httparty'

class YahooFinance
  include HTTParty
  base_uri 'query.yahooapis.com/'
  default_params format: "json", diagnostics: true, env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  # Grabs stock data from symbols and returns an array of data results
  # symbols is an array of strings
  def self.get_data(symbols)
    querystring = ""
    *rest, last = symbols
    rest.each do |r|
      querystring += r.upcase + "', '"
    end
    querystring += last.upcase if last
    response = get '/v1/public/yql', query: { q: "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('" + querystring + "')" }
    if response.success?
      response = response["query"]["results"]["quote"]
      response = [response] unless response.kind_of?(Array)
      results = Hash.new
      response.each do |r|
        results[r["symbol"]] = {
          name: r["Name"],
          price: r["LastTradePriceOnly"],
          change: r["Change"],
          eps: r["EarningsShare"]
        }
      end
      return results
    end
  end
end