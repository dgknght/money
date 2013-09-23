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
  belongs_to :entity

  LEFT_SIDE = %w(asset expense)
  RIGHT_SIDE = %w(liability equity income)
  ACCOUNT_TYPES = LEFT_SIDE + RIGHT_SIDE
  
  class << self
    ACCOUNT_TYPES.each do |type|
      define_method "#{type}_type" do
        type
      end
    end
  end
  
  validates :account_type, presence: true, 
                           inclusion: { in: ACCOUNT_TYPES }
  
  scope :asset, -> { where(account_type: Account.asset_type) }
  scope :liability, -> { where(account_type: Account.liability_type) }
  scope :equity, -> { where(account_type: Account.equity_type) }
  scope :income, -> { where(account_type: Account.income_type) }
  scope :expense, -> { where(account_type: Account.expense_type) }
  
  # Adjusts the balance of the account by the specified amount
  def credit(amount)
    amount = 0 - amount if LEFT_SIDE.include?(account_type)
    self.balance += amount
  end
  
  def credit!(amount)
    credit(amount)
    save!
  end
  
  # Adjusts the balance of the account by the specified amount
  def debit(amount)
    amount = 0 - amount if RIGHT_SIDE.include?(account_type)
    self.balance += amount
  end
  
  def debit!(amount)
    debit(amount)
    save!
  end
end
