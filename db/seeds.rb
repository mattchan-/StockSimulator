# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

companies = JSON.parse(IO.read("company_list.json"))

companies["query"]["results"]["industry"].each do |i|
  if i["company"]
    i["company"] = [i["company"]] unless i["company"].kind_of?(Array)
    i["company"].each do |j|
      Company.create(name: j["name"], symbol: j["symbol"].upcase)
    end
  end
end

companies2 = JSON.parse(IO.read("company_list2.json"))

companies2.each do |i|
  if Company.find_by(symbol: i["Ticker"]).nil?
    Company.create(name: i["Name"], symbol: i["Ticker"])
  end
end