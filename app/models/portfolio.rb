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
end
