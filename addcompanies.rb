companies = JSON.parse(IO.read("company_list.json"))

companies["query"]["results"]["industry"].each do |i|
  if i["company"]
    i["company"] = [i["company"]] unless i["company"].kind_of?(Array)
      i["company"].each do |j|
      Company.create(name: j["name"], symbol: j["symbol"])
    end
  end
end