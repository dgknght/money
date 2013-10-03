module TransactionsHelper
  def available_accounts(entity)
    {
      'Assets'      => to_flat_array(entity.accounts.asset),
      'Liabilities' => to_flat_array(entity.accounts.liability),
      'Equity'      => to_flat_array(entity.accounts.equity),
      'Income'      => to_flat_array(entity.accounts.income),
      'Expense'     => to_flat_array(entity.accounts.expense),
    }
  end
  
  private
    def to_flat_array(accounts)
      accounts.map do |account|
        [account, account.children]
      end.flatten.map { |a| [a.path, a.id] }
    end
end
