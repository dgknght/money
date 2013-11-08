# == Schema Information
#
# Table name: entities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  name       :string(100)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Entity < ActiveRecord::Base
  validates_presence_of :name, :user_id
  
  belongs_to :user
  has_many :accounts
  has_many :transactions
  has_many :budgets
end
