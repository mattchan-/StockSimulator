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
  validates :symbol, presence: true, inclusion: { in: Company.all.pluck(:symbol), message: " must be a valid ticker" }
  validates :date_acquired, presence: true
  validates :shares, :cost_per_share, :portfolio_id, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :portfolio

  def total_cost
    self[:cost_per_share] * self[:shares]
  end
end
