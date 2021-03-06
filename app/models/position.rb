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
#  cumulative_dividends :float
#  price                :float
#

class Position < ActiveRecord::Base
  before_create :upcase_symbol

  after_create :get_price, :get_cumulative_dividends

  validate :check_valid_symbol, on: :create

  validates :symbol, presence: true
  validates :date_acquired, presence: true
  validates :shares, :cost_per_share, :portfolio_id, presence: true, numericality: { greater_than: 0 }

  belongs_to :portfolio

  # Localization
  include I18n::Alchemy
  localize :date_acquired, using: :date

  def get_price
    update price: Company.find_by(symbol: self[:symbol]).price
  end

  def get_cumulative_dividends
    update cumulative_dividends: (dividend_list.pluck(:value).reduce(0, :+) * self[:shares])
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

  def check_valid_symbol
    errors.add(:symbol, "must be a valid Yahoo Finance ticker") unless Company.check(self[:symbol])
  end

  def dividend_list
    CompanyData.where("symbol = ? AND category = ? AND date > ?", self[:symbol], "dividend", self[:date_acquired])
  end

  private
    def upcase_symbol
      self[:symbol].upcase!
    end
end
