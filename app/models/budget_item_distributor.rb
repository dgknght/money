class BudgetItemDistributor
  def self.distribute(budget_item, method, *args)
    distribute_average(budget_item, *args) if method == :average
  end
  
  private
    def self.distribute_average(budget_item, amount)
      budget_item.periods.each { |p| p.budget_amount = amount }      
    end
end