class BudgetItemDistributor
  def self.distribute(budget_item, method, *args)
    full_method_name = "distribute_#{method}"
    raise "unrecognized method '#{method}'" unless respond_to?(full_method_name)
    send full_method_name, budget_item, *args
  end
  
  private
    def self.distribute_average(budget_item, amount)
      budget_item.periods.each { |p| p.budget_amount = amount }      
    end
    
    def self.distribute_direct(budget_item, amounts)
      validate_amounts budget_item, amounts
      
      amounts.each_with_index { |a, i| budget_item.periods[i].budget_amount = a }
    end
    
    def self.distribute_total(budget_item, total)
      amount = total / budget_item.periods.length
      budget_item.periods.each { |p| p.budget_amount = amount }
    end
    
    def self.validate_amounts(budget_item, amounts)
      raise "amounts must be an array" unless amounts.respond_to?('length')
      unless budget_item.periods.length == amounts.length
        raise "incorrect number of elements. expected #{budget_item.periods.length}, received #{amounts.length}"
      end
    end
end