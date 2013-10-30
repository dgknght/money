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
  
  # The amount to be applied to each budget
  # period by the 'average' method
  def amount
    return amounts.length == 0 ? nil : total / amounts.length
  end

  # The individual amounts that have been applied
  # to each period in the budget by the 'direct' method
  def amounts
    @budget_item.periods.map { |p| p.budget_amount }
  end

  # Sets the values that are to be applied
  # to the budget periods.
  #
  # These are specified to each method of
  # distributing the amounts
  def apply_attributes(attributes = {})
    self.method = attributes[:method]
    self.options = attributes[:options]
  end
  
  # Applies amounts to each period in the budget
  # item according the options specified in apply_attributes
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

  # Gets the total amount of money applied to the budget item
  def total
    return nil if amounts.none?
    return amounts.reduce(0) { |s, a| s += a}
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
