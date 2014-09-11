require 'rubygems'
require 'httparty'
require "csv.rb"
require "date.rb"
require "open-uri.rb"

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

  def self.exists?(symbol)
    symbol = symbol.upcase
    startDate = Date.today - 7
    endDate = Date.today

    # URL Parameter Values:
    # s  Stock Ticker (for example, MSFT)
    # a  Start Month (0-based; 0=January, 11=December)
    # b  Start Day
    # c  Start Year
    # d  End Month (0-based; 0=January, 11=December)
    # e  End Day
    # f  End Year
    # g  Always use the letter d for daily quotes
    # example url: "http://ichart.finance.yahoo.com/x?s=IBM&a=00&b=2&c=1962&d=04&e=25&f=2011&g=d&y=0&z=30000"
    url = "http://ichart.finance.yahoo.com/x?s=#{symbol}&a=#{startDate.month-1}&b=#{startDate.day}&c=#{startDate.year}&d=#{endDate.month-1}&e=#{endDate.day}&f=#{endDate.year}&g=d&y=0&z=30000"
    begin
      open(url) do |file|
        value = 0
        CSV.new(file, return_headers: false).each do |row|
          next unless row[0].strip.to_i.to_s == row[0].strip
          d = self.quote(symbol)
          name = d ? d["Name"] : false
          return { symbol: symbol, name: name, date: Date.strptime(row[0].strip, "%Y%m%d"), value: row[4].to_f } if name
        end
        return false
      end
    rescue
      false
    end
  end

  def self.getAllData(symbol, startDate = Date.strptime("1990-01-01", "%Y-%m-%d"))
    symbol = symbol.upcase
    startDate = startDate == nil ? Date.strptime("1990-01-01", "%Y-%m-%d") : startDate
    endDate = Date.today
    data = []

    # URL Parameter Values:
    # s  Stock Ticker (for example, MSFT)
    # a  Start Month (0-based; 0=January, 11=December)
    # b  Start Day
    # c  Start Year
    # d  End Month (0-based; 0=January, 11=December)
    # e  End Day
    # f  End Year
    # g  Always use the letter d for daily quotes
    # example url: "http://ichart.finance.yahoo.com/x?s=IBM&a=00&b=2&c=1962&d=04&e=25&f=2011&g=d&y=0&z=30000"
    url = "http://ichart.finance.yahoo.com/x?s=#{symbol}&a=#{startDate.month-1}&b=#{startDate.day}&c=#{startDate.year}&d=#{endDate.month-1}&e=#{endDate.day}&f=#{endDate.year}&g=d&y=0&z=30000"
    begin
      open(url) do |file|
        value = 0
          # Due to the data strcuture (splits show up before the day's data) we need to know both the old and new split factors, and for processing purposes, the cumulative split factor
        old_split_factor = current_split_factor = cumulative_split_factor = 1
          # last_split_date needed for comparison to the date currently being processed to adjust closing price for splits
        last_split_date = Date.today + 1

        CSV.new(file, return_headers: false).each do |row|
          if row[0] == "DIVIDEND"
            data.push({symbol: symbol, category: row[0].downcase, date: Date.strptime(row[1].strip, "%Y%m%d"), value: row[2].to_f})
          elsif row[0] == "SPLIT"
              # Set new split factor
            old_split_factor = cumulative_split_factor
              # Split factor represents the # of today's shares that are equivalent to 1 share at the processing date
            current_split_factor = row[2].split(":")[0].to_f / row[2].split(":")[1].to_f
            cumulative_split_factor *= current_split_factor
            last_split_date = Date.strptime(row[1].strip, "%Y%m%d")
            data.push({symbol: symbol, category: row[0].downcase, date: last_split_date, value: current_split_factor})
          else
            next unless row[0].strip.to_i.to_s == row[0].strip
            current_date = Date.strptime(row[0].strip, "%Y%m%d")
              # historical price must be divided by split factor to get the split_adjusted price
            value = current_date < last_split_date ? row[4].to_f / cumulative_split_factor : row[4].to_f / old_split_factor
            data.push(symbol: symbol, category: "close", date: Date.strptime(row[0].strip, "%Y%m%d"), value: value)
          end
        end
        return data
      end
    rescue
      false
    end
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