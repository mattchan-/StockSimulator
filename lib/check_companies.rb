require "./config/environment"

# startMonth = Position.find(141).date_acquired.month
# startYear = Position.find(141).date_acquired.year
# endMonth = Date.today.month
# endYear = Date.today.year

# month = startMonth
# a = []
# for year in (startYear..endYear)
#   if year == endYear
#     while month <= endMonth
#       a.push(CompanyData.where("symbol = ? AND strftime('%m', date) + 0 = ? AND strftime('%Y', date) + 0 = ?", "DIS", month, year).order("date ASC").first)
#       month += 1
#     end
#   else
#     while month <= 12
#       a.push(CompanyData.where("symbol = ? AND strftime('%m', date) + 0 = ? AND strftime('%Y', date) + 0 = ?", "DIS", month, year).order("date ASC").first)
#       month += 1
#     end
#     month = 1
#   end
# end

# puts a.inspect
st = Time.now
raw_data = CompanyData.where("symbol = ? AND category = ? AND date > ?", "DIS", "close", Date.strptime("19900205","%Y%m%d")).order("date ASC")

month = raw_data.first.date.month
data = []
raw_data.each do |d|
  if d.date.month == month
    data.push(d)
    if month == 12
      month = 1
    else
      month += 1
    end
  end
end

puts data.count
puts "Finished in #{Time.now - st} seconds"