class BudgetMonitor < ActiveRecord::Base
  belongs_to :entity
  belongs_to :account

  validates_presence_of :account_id, :entity_id

  def budget_amount

    puts "budgets=#{Budget.all.inspect}"
    puts "today is #{Date.today}"

    budget = Budget.current
    budget_item = budget.item_for(account)
    period = budget_item.current_period
    period.budget_amount * progress
  end

  def current_amount
    50
  end

  private

  def progress
    today = Date.today
    days_in_month = Date.days_in_month(today.year, today.month)
    today.day / days_in_month
  end
end
