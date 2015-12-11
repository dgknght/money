class BalanceSheetFilter < Filter
  attr_accessor :as_of , :hide_zero_balances
  alias_method :hide_zero_balances?, :hide_zero_balances
  
  def initialize(attributes = {})
    attributes ||= {}
    self.as_of = Filter.date_value(attributes[:as_of])
    self.hide_zero_balances = attributes.fetch(:hide_zero_balances, true)
  end
end
