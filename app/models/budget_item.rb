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
  has_many :periods, class_name: BudgetItemPeriod
  
  validates_presence_of :budget_id, :account_id
  validates_uniqueness_of :account_id, scope: :budget_id
  
#  before_validation :add_periods
#  before_validation_on_update :update_periods
  
  private
    def add_periods
      # Need to be able to support various period lengths (weekly, biweekly, etc.)
      # For now, we're just supporting monthly
      period_start = budget.start_date
      while period_start < budget.end_date
        periods.new(start_date: period_start, budget_amount: 0)
        period_start = period_start >> 1
      end
    end
    
    def update_periods
    end
end
