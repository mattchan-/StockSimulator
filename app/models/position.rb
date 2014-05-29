# == Schema Information
#
# Table name: positions
#
#  id            :integer          not null, primary key
#  portfolio_id  :integer
#  ticker        :string(255)
#  quantity      :integer
#  cost_basis    :float
#  created_at    :datetime
#  updated_at    :datetime
#  date_acquired :date
#

class Position < ActiveRecord::Base
  validates :ticker, :date_acquired, presence: true
  validates :quantity, :cost_basis, :portfolio_id, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :portfolio

  def cost_per_share
    self[:cost_basis]/self[:quantity]
  end
end
