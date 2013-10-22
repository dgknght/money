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
  
  validates_presence_of :budget_id, :account_id
  validates_uniqueness_of :account_id, scope: :budget_id
end
