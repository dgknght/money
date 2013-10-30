# == Schema Information
#
# Table name: budget_items
#
#  id         :integer          not null, primary key
#  budget_id  :integer          not null
#  account_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class BudgetItem < ActiveRecord::Base
  belongs_to :budget
  belongs_to :account
  has_many :periods, class_name: BudgetItemPeriod, inverse_of: :budget_item, validate: false, autosave: true, dependent: :destroy
  
  validates_presence_of :budget_id, :account_id
  validates_uniqueness_of :account_id, scope: :budget_id
  
  before_validation :sync_periods
  
  scope :income, -> { joins(:account).where('accounts.account_type=?', Account.income_type) }
  scope :expense, -> { joins(:account).where('accounts.account_type=?', Account.expense_type) }
  def sync_periods
    return unless budget
    
    budget.periods.each_with_index do |p, i|
      if periods.length <= i
        period = periods.build(start_date: p.start_date, budget_amount: 0)
      else
        period = periods[i]
        period.start_date = p.start_date
      end
    end
  end
end
