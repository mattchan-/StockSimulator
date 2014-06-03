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
#  price          :float
#

class Position < ActiveRecord::Base
  before_create :upcase_symbol

  validates :symbol, presence: true, inclusion: { in: Company.all.pluck(:symbol), message: " must be a valid ticker" }
  validates :date_acquired, presence: true
  validates :shares, :cost_per_share, :portfolio_id, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :portfolio

  def total_cost
    (self[:cost_per_share] * self[:shares])
  end

  # Localization
  include I18n::Alchemy
  localize :date_acquired, using: :date

  # HTTParty
  include HTTParty
  base_uri 'query.yahooapis.com'
  default_params format: "json", env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  debug_output $stderr

  def get_cumulative_dividends
    query = "use 'store://bg2cgClQyQC1c5gJE3UXUn' as yahoo.finance.dividendhistory; select * from yahoo.finance.dividendhistory where symbol = '" + self[:symbol] + "' and startDate = '" + self[:date_acquired].strftime("%Y-%m-%d") + "' and endDate = '" + Date.today.strftime("%Y-%m-%d") + "'"
    response = self.class.get '/v1/public/yql', query: { q: query }
    cumulative_dividends = 0.0
    if response.success? && response["query"]["results"] != nil
      response = response["query"]["results"]["quote"]
      response = [response] unless response.kind_of?(Array)
      response.each do |r|
        cumulative_dividends += r["Dividends"].to_f
      end
    end
    update_attributes cumulative_dividends: cumulative_dividends * self[:shares]
  end

  def update_price
    query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('" + self[:symbol] + "')"
    response = self.class.get '/v1/public/yql', query: { q: query }
    if response.success?
      if response["query"]["results"]["quote"]["ErrorIndicationreturnedforsymbolchangedinvalid"].nil?
        return -1
      else
        update_attributes price: response["query"]["results"]["quote"]["LastTradePriceOnly"].to_f
      end
    end
  end

  def price
    # If the stock market is open, update the price
    # Returns last market price

    t=Time.now.in_time_zone('Eastern Time (US & Canada)')
    market_open = Time.new(t.year, t.month, t.day, 9, 30)
    market_close  = Time.new(t.year, t.month, t.day, 16)

    update_price if t.between?(market_open, market_close)
    
    self[:price]
  end

  def total_market_value
    self[:price] * self[:shares]
  end

  def unrealized_gain
    total_market_value - total_cost
  end

  def total_profit
    unrealized_gain + self[:cumulative_dividends]
  end

  private
    def upcase_symbol
      self[:symbol].upcase!
    end
end
