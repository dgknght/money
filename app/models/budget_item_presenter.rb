class BudgetItemPresenter
  include ActiveModel::Validations
  
  attr_accessor :method, :account_id  
  
  validates_presence_of :method, :account_id
  
  def budget_item
    return budget_item_average if method == :average
  end
  
  def initialize(budget_item, attributes = {})
    @budget_item
    self.method = attributes[:method]
    self.account_id = attributes[:account_id]
  end
  
  private
    def budget_item_average
      
    end
end