class BudgetItemDistributor
  METHODS = %w(average direct total)
  class << self 
    METHODS.each do |method|
      define_method method do
        method
      end
    end
    
    def methods
      METHODS
    end
  end
  
  attr_accessor :method, :options
  
  def apply_attributes(attributes = {})
    self.method = attributes[:method]
    self.options = attributes[:options]
  end
  
  def distribute
    raise "method must be set before calling distribute" unless method
    raise "options must be set before calling distribute" unless options
    full_method_name = "distribute_#{method}"
    raise "unrecognized distribution method '#{method}'" unless respond_to?(full_method_name, true)
    @budget_item.sync_periods
    send full_method_name
  end
  
  def initialize(budget_item)
    @budget_item = budget_item
  end
  
  private
    def distribute_average
      amount = validate_average_options
      @budget_item.periods.each { |p| p.budget_amount =  amount}
    end
    
    def distribute_direct
      amounts = validate_direct_options
      amounts.each_with_index { |a, i| @budget_item.periods[i].budget_amount = a }
    end
    
    def distribute_total
      total = validate_total_options
      amount = total / @budget_item.periods.length
      @budget_item.periods.each { |p| p.budget_amount = amount }
    end
    
    def get_number(value)
      return BigDecimal.new(value) if value.is_a?(String)
      value
    end
    
    def indifferent_access_options
      options.with_indifferent_access
    end
    
    def validate_average_options
      amount = indifferent_access_options[:amount]
      raise "amount must be specified" unless amount
      amount
    end
    
    def validate_direct_options
      amounts = indifferent_access_options[:amounts]
      raise "amounts must be specified" unless amounts
      raise "amounts must be an array" unless amounts.respond_to?('length')
      unless @budget_item.periods.length == amounts.length
        raise "incorrect number of elements. expected #{budget_item.periods.length}, received #{amounts.length}"
      end
      
      return amounts.values if amounts.respond_to?(:values)
      amounts
    end
    
    def validate_total_options
      total = indifferent_access_options[:total]
      raise "total must be specified" unless total
      get_number(total)
    end
end