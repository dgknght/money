module BudgetItemsHelper
  def account_options(budget_item)
    accounts = available_accounts(budget_item.budget.entity)
    grouped_options_for_select accounts, budget_item.account_id
  end
  
  private
    def available_accounts(entity)
      ['Asset', 'Liability', 'Equity', 'Income', 'Expense'].map do |label|
        [
          label,
          entity.accounts.where(['account_type=?', label.downcase]).map do |account|
            [account.name, account.id]
          end
        ]
      end
    end
end
