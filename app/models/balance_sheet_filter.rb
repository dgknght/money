class BalanceSheetFilter
  attr_accessor :as_of
  
  def initialize(attributes = {})
    attributes ||= {}
    self.as_of = get_date(attributes[:as_of])
  end
  
  private
    def get_date(value)      
      return value if value.is_a?(Date)
      
      begin
        return Date.parse(value)
      rescue
        return Date.today
      end
    end
end