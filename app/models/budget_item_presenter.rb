class BudgetItemPresenter
  include ActiveModel::Validations
  
  attr_accessor :method
  
  validates_presence_of :method
  
  def budget_item
  end
  
  def initialize(budget, attributes = {})
    @budget = budget
    self.method = attributes[:method]
  end
end