module BudgetItemsHelper
  def account_options(budget_item)
    accounts = available_accounts(budget_item.budget.entity)
    grouped_options_for_select accounts, budget_item.account_id
  end
  
  private
    def available_accounts(entity)
      {
        'Assets'      => Account.asset,
        'Liabilities' => Account.liability,
        'Equity'      => Account.equity,
        'Income'      => Account.income,
        'Expense'     => Account.expense
      }
    end
end
