module BudgetMonitorsHelper
  def budget_days_available
    Time.days_in_month(Date.today.month, Date.today.year)
  end

  def budget_days_past
    Date.today.day
  end
end
