class Account < ActiveRecord::Base
  attr_accessible :name, :account_type
  belongs_to :user

  ACCOUNT_TYPES = [:asset, :liability, :equity]

  validates :account_type, presence: true, 
                           inclusion: { in: ACCOUNT_TYPES }
  
  scope :assets, -> { where(account_type: :asset) }
  scope :liabilities, -> { where(account_type: :liability) }
  scope :equities, -> { where(account_type: :equity) }
end
