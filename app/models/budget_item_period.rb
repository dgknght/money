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
  belongs_to :budget_item
  
  validates_presence_of :budget_item_id, :start_date, :budget_amount
end
