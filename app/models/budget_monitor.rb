class BudgetMonitor < ActiveRecord::Base
  belongs_to :entity
  belongs_to :account

  validates_presence_of :account_id, :entity_id

  def budget_amount
    100
  end

  def current_amount
    50
  end
end
