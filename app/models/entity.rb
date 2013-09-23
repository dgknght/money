class Entity < ActiveRecord::Base
  attr_accessible :name, :user_id
  
  validates_presence_of :name, :user_id
  
  belongs_to :user
  has_many :accounts
  has_many :transactions
end
