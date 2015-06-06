# == Schema Information
#
# Table name: budget_item_periods
#
#  id             :integer          not null, primary key
#  budget_item_id :integer          not null
#  start_date     :date             not null
#  budget_amount  :decimal(, )      not null
#  created_at     :datetime
#  updated_at     :datetime
#

class BudgetItemPeriod < ActiveRecord::Base
  belongs_to :budget_item, inverse_of: :periods
  
  validates_presence_of :budget_item_id, :start_date, :budget_amount
  
  default_scope { order(:start_date) }
  
  def actual_amount
    budget_item.account.balance_with_children_between(start_date, end_date)
  end

  def end_date
    next_period = budget_item.periods.select{ |p| p.start_date > start_date}.first
    next_period ? next_period.start_date - 1 : budget_item.budget.end_date
  end
end
