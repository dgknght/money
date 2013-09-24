# == Schema Information
#
# Table name: entities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  name       :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Entity < ActiveRecord::Base
  attr_accessible :name, :user_id
  
  validates_presence_of :name, :user_id
  
  belongs_to :user
  has_many :accounts
  has_many :transactions
end
