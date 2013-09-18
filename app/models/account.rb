# == Schema Information
#
# Table name: accounts
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  account_type :string(255)      not null
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  balance      :decimal(, )      default(0.0), not null
#

class Account < ActiveRecord::Base
  attr_accessible :name, :account_type, :balance
  belongs_to :user
  before_validation :symbolize_account_type

  ACCOUNT_TYPES = [:asset, :liability, :equity, :income, :expense]

  validates :account_type, presence: true, 
                           inclusion: { in: ACCOUNT_TYPES }
  
  scope :assets, -> { where(account_type: :asset) }
  scope :liabilities, -> { where(account_type: :liability) }
  scope :equity, -> { where(account_type: :equity) }
  scope :income, -> { where(account_type: :income) }
  scope :expense, -> { where(account_type: :expense) }
  
  private
    def symbolize_account_type
      self.account_type = account_type.to_sym unless self.account_type.nil? || self.account_type.class == Symbol
    end
end
