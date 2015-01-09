class BudgetMonitor < ActiveRecord::Base
  belongs_to :entity
  belongs_to :account

  delegate :start_date, :end_date, to: :period
  validates_presence_of :account_id, :entity_id

  def available_days
    (end_date - start_date) + 1
  end

  def budget_amount
    period.budget_amount * progress
  end

  def current_amount
    items.reduce(0) { |sum, item| sum + item.polarized_amount }
  end

  def past_days
    (Date.today - start_date) + 1
  end

  private

  def get_period
    budget = Budget.current
    budget.
      item_for(account).
      current_period
  end

  def items
    account.transaction_items.
      joins(:transaction).
      where(['transaction_date >= ? and transaction_date <= ?',
             start_date,
             Date.today])
  end

  def period
    @period ||= get_period
  end

  def progress
    today = Date.today
    days_in_month = Time.days_in_month(today.month, today.year)
    today.day.to_f / days_in_month.to_f
  end
end
