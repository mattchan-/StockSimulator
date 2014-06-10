# == Schema Information
#
# Table name: positions
#
#  id                   :integer          not null, primary key
#  portfolio_id         :integer
#  symbol               :string(255)
#  shares               :integer
#  cost_per_share       :float
#  created_at           :datetime
#  updated_at           :datetime
#  date_acquired        :date
#  price                :float
#  cumulative_dividends :float
#

class Position < ActiveRecord::Base
  before_create :upcase_symbol
  after_create :update_price, :update_cumulative_dividends

  validates :symbol, presence: true, inclusion: { in: Company.all.pluck(:symbol), message: " must be a valid ticker" }
  validates :date_acquired, presence: true
  validates :shares, :cost_per_share, :portfolio_id, presence: true, numericality: { greater_than: 0 }

  belongs_to :portfolio

  # Localization
  include I18n::Alchemy
  localize :date_acquired, using: :date

  # HTTParty
  include HTTParty
  base_uri 'query.yahooapis.com'
  default_params format: "json", env: "store://datatables.org/alltableswithkeys", callback: ''
  format :json

  debug_output $stderr

  def update_cumulative_dividends
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
    update_attributes cumulative_dividends: (cumulative_dividends * self[:shares]).to_f
  end

  def update_price
    query = "SELECT * FROM yahoo.finance.quotes WHERE symbol in ('" + self[:symbol] + "')"
    response = self.class.get '/v1/public/yql', query: { q: query }
    if response.success? && response["query"]["results"]["quote"]["ErrorIndicationreturnedforsymbolchangedinvalid"] == nil
        update_attributes price: response["query"]["results"]["quote"]["LastTradePriceOnly"].to_f
    end
  end

  def market_open?
    # returns true if the stock market is open

    t=Time.now.in_time_zone('Eastern Time (US & Canada)')
    market_open = Time.new(t.year, t.month, t.day, 9, 30, 0, t.utc_offset)
    market_close  = Time.new(t.year, t.month, t.day, 16, 0, 0, t.utc_offset)

    t.between?(market_open, market_close)
  end

  def position_cost
    self[:cost_per_share] * self[:shares]
  end

  def market_value
    self[:price] * self[:shares]
  end

  def unrealized_gains
    return market_value - position_cost
  end

  def profit
    unrealized_gains + self[:cumulative_dividends]
  end

  def profit_percentage
    profit / position_cost * 100
  end

  private
    def upcase_symbol
      self[:symbol].upcase!
    end
end
