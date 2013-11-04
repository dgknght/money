# Defines methods used to filter the content of a budget report
class BudgetFilter < Filter
  attr_accessor :start_date, :end_date, :budget_id

  validates_presence_of :start_date, :end_date, :budget_id

  def initialize(attr = {})
    attributes = (attr || {}).with_indifferent_access
    self.start_date = Filter.date_value(attributes[:start_date], default_start_date)
    self.end_date = Filter.date_value(attributes[:end_date], default_end_date)
    self.budget_id = attributes[:budget_id]
  end

  def inspect
    "[BudgetFilter: start=#{start_date}, end=#{end_date}, budget_id=#{budget_id}]"
  end
  
  private
    # returns the last day of the previous month, unless it is
    # January, in which case it returns today
    def default_end_date
      today = Date.today
      return today if today.month == 1
      Date.civil(today.year, today.month, 1).prev_day
    end
    
    # return the first day of the current year
    def default_start_date
      today = Date.today
      Date.civil(today.year, 1, 1)
    end
end
