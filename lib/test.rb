!/usr/bin/env ruby

require "csv.rb"
require "date.rb"
require "open-uri.rb"
require "./config/environment"

def getAllData(symbol)
  symbol = symbol.upcase
  startDate = Date.strptime("1990-01-01", "%Y-%m-%d")
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
  # example url: "http://ichart.finance.yahoo.com/x?s=IBM&a=00&b=2&c=1962&d=04&e=25&f=2011&g=v&y=0&z=30000"
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

d = []

Position.pluck(:symbol).uniq.each do |a|
  a = a.upcase
  startTime = Time.now
  initCount = CompanyData.where(symbol: a).count

  d = YQL.getAllData(a)
  if !d
    puts "Data for #{a} not found"
  else
    d.each do |d|
      CompanyData.where(symbol: d[:symbol], category: d[:category], date: d[:date], value: d[:value].to_f.round(4)).first_or_create
    end
    puts "#{CompanyData.where(symbol: a).count - initCount} entries for #{a} created in #{Time.now - startTime} seconds."
  end
end