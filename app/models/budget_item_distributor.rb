class BudgetItemDistributor
  def self.methods
    %w(average direct total)
  end
  
  def self.distribute(budget_item, method, options)
    full_method_name = "distribute_#{method}"
    raise "unrecognized method '#{method}'" unless respond_to?(full_method_name)
    budget_item.sync_periods
    send full_method_name, budget_item, options.with_indifferent_access
  end
  
  private
    def self.distribute_average(budget_item, options)
      budget_item.periods.each { |p| p.budget_amount = options[:amount] }
    end
    
    def self.distribute_direct(budget_item, options)
      amounts = options[:amounts]
      validate_amounts budget_item, amounts
      
      amounts.each_with_index { |a, i| budget_item.periods[i].budget_amount = a }
    end
    
    def self.distribute_total(budget_item, options)
      amount = options[:total] / budget_item.periods.length
      budget_item.periods.each { |p| p.budget_amount = amount }
    end
    
    def self.get_number(value)
      return BigDecimal.new(value) if value.is_a?(String)
      value
    end
    
    def self.validate_amounts(budget_item, amounts)
      raise "amounts must be an array" unless amounts.respond_to?('length')
      unless budget_item.periods.length == amounts.length
        raise "incorrect number of elements. expected #{budget_item.periods.length}, received #{amounts.length}"
      end
    end
end