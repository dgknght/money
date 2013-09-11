class Account < ActiveRecord::Base
  attr_accessible :name, :account_type
  belongs_to :user
  
  def self.asset
    'asset'
  end
end
