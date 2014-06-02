# == Schema Information
#
# Table name: positions
#
#  id             :integer          not null, primary key
#  portfolio_id   :integer
#  symbol         :string(255)
#  shares         :integer
#  cost_per_share :float
#  created_at     :datetime
#  updated_at     :datetime
#  date_acquired  :date
#

class Position < ActiveRecord::Base
  before_validation :upcase_symbol

  validates :symbol, presence: true, inclusion: { in: Company.all.pluck(:symbol), message: " must be a valid ticker" }
  validates :date_acquired, presence: true
  validates :shares, :cost_per_share, :portfolio_id, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :portfolio

  def total_cost
    (self[:cost_per_share] * self[:shares])
  end

  # HTTParty
  include HTTParty
  base_uri 'query.yahooapis.com'
  default_params format: "json", diagnostics: true, env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  debug_output $stderr

  def get_cumulative_dividends
    query = "use 'store://bg2cgClQyQC1c5gJE3UXUn' as yahoo.finance.dividendhistory; select * from yahoo.finance.dividendhistory where symbol = '" + self[:symbol] + "' and startDate = '" + self[:date_acquired].strftime("%Y-%m-%d") + "' and endDate = '" + Date.today.strftime("%Y-%m-%d") + "'"
    response = self.class.get '/v1/public/yql', query: { q: query }
    cumulative_dividends = 0.0
    if response.success?
      return 0 if response["query"]["results"] == nil
      response = response["query"]["results"]["quote"]
      response = [response] unless response.kind_of?(Array)
      response.each do |r|
        cumulative_dividends += r["Dividends"].to_f
      end
      return cumulative_dividends * self[:shares]
    end
  end

  private
    def upcase_symbol
      self[:symbol].upcase!
    end

    def parse_date_acquired(date)
      Date.strptime(date, '%m/%d/%Y')
    end
end
