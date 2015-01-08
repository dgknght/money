class BudgetMonitor < ActiveRecord::Base
  belongs_to :entity
  belongs_to :account

  validates_presence_of :account_id, :entity_id

  def budget_amount
    puts "full_budget_amount=#{full_budget_amount}"
    puts "progress=#{progress}"

    full_budget_amount * progress
  end

  def current_amount
    50
  end

  private

  def full_budget_amount
    @full_budget_amount ||= get_budget_amount
  end

  def get_budget_amount
    budget = Budget.current

    puts "#{budget.items.length} item(s)"
    puts "account=#{budget.items[0].account.name}"
    puts "period amounts #{budget.items[0].periods.map{|p| p.budget_amount.to_s}}"

    budget.
      item_for(account).
      current_period.
      budget_amount
  end

  def progress
    today = Date.today
    days_in_month = Time.days_in_month(today.month, today.year)
    today.day.to_f / days_in_month.to_f
  end
end
