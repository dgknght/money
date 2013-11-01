# Defines methods used to filter the content of a budget report
class BudgetFilter < Filter
  attr_accessor :start_date, :end_date, :budget_id

  validates_presence_of :start_date, :end_date, :budget_id

  def initialize(attr = {})
    attributes = (attr || {}).with_indifferent_access
    self.start_date = Filter.date_value(attributes[:start_date])
    self.end_date = Filter.date_value(attributes[:end_date])
    self.budget_id = attributes[:budget_id]
  end

  def inspect
    "[BudgetFilter: start=#{start_date}, end=#{end_date}, budget_id=#{budget_id}]"
  end
end
