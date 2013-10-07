class IncomeStatementFilter < Filter
  attr_accessor :from, :to
  
  validate :to_cannot_precede_from
  
  def initialize (attributes = {})
    attributes ||= {}
    self.from = Filter.date_value(attributes[:from], previous_month_start)
    self.to = Filter.date_value(attributes[:to], previous_month_end)
  end
  
  private
    def to_cannot_precede_from
      if to < from
        errors.add :to, 'cannot precede the start date'
      end
    end
    
    def previous_month_end
      today = Date.today << 1
      Date.civil(today.year, today.month, -1)
    end
    
    def previous_month_start
      today = Date.today << 1
      Date.civil(today.year, today.month, 1)
    end
end