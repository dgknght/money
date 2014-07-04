class BalanceSheetFilter < Filter
  attr_accessor :as_of
  
  def initialize(attributes = {})
    attributes ||= {}
    self.as_of = Filter.date_value(attributes[:as_of])
  end
end