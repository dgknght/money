module BudgetItemsHelper
  def account_options(budget_item)
    accounts = available_accounts(budget_item.budget.entity)
    grouped_options_for_select accounts, budget_item.account_id
  end

  def columnize(items, column_count)
    row_count = (items.count / column_count).ceil
    result = Hash.new{|h, k| h[k] = []}
    indexed_items = items.each_with_index do |item, index|
      group_index = index % row_count
      result[group_index] << [item, index]
    end
    result.keys.sort.map{|k| result[k]}.transpose
  end
  
  private
    def available_accounts(entity)
      ['Income', 'Expense'].map do |label|
        [
          label,
          entity.accounts.where(['account_type=?', label.downcase]).map do |account|
            [account.name, account.id]
          end
        ]
      end
    end
end
