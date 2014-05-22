# == Schema Information
#
# Table name: positions
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  ticker       :string(255)
#  quantity     :integer
#  cost_basis   :float
#  created_at   :datetime
#  updated_at   :datetime
#

class Position < ActiveRecord::Base
  validates :ticker, presence: true
  validates :quantity, :cost_basis, :portfolio_id, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :portfolio
end
