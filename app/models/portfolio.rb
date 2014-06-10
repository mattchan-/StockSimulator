# == Schema Information
#
# Table name: portfolios
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Portfolio < ActiveRecord::Base
  validates :name, presence: true

  has_many :positions, dependent: :destroy
  accepts_nested_attributes_for :positions

  def total_cost
    total_cost = 0
    self.positions.each do |p|
      total_cost += p.position_cost
    end
    return total_cost
  end

  def total_market_value
    total_market_value = 0
    self.positions.each do |p|
      total_market_value += p.market_value
    end
    return total_market_value
  end

  def total_unrealized_gains
    total_unrealized_gains = 0
    self.positions.each do |p|
      total_unrealized_gains += p.unrealized_gains
    end
    return total_unrealized_gains
  end

  def total_cumulative_dividends
    self.positions.pluck(:cumulative_dividends).reduce(0, :+)
  end

  def total_profit
    total_profit = 0
    self.positions.each do |p|
      total_profit += p.profit
    end
    return total_profit
  end

  def total_profit_percentage
    if total_cost != 0
      total_profit / total_cost * 100
    else
      0
    end
  end
end
