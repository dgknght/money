class BudgetMonitor < ActiveRecord::Base
  belongs_to :entity
  belongs_to :account

  validates_presence_of :account_id, :entity_id

  def budget_amount
    period.budget_amount * progress
  end

  def current_amount
    account.transaction_items.
      where(['transaction_date >= ? and transaction_date <= ?', start_date, end_date]).
      reduce(0) { |sum, item| sum + item.polarized_amount }
  end

  private

  def end_date
    period.end_date
  end

  def get_period
    budget = Budget.current
    budget.
      item_for(account).
      current_period
  end

  def period
    @period ||= get_period
  end

  def progress
    today = Date.today
    days_in_month = Time.days_in_month(today.month, today.year)
    today.day.to_f / days_in_month.to_f
  end

  def start_date
    period.start_date
  end
end
