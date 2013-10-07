module TransactionHelpers
  def create_transaction(entity, amount, credit_account, debit_account, *attr)
    attributes = attr.extract_options!.merge(items_attributes: [
      {account_id: credit_account.id, action: TransactionItem.credit, amount: amount}, 
      {account_id: debit_account.id, action: TransactionItem.debit, amount: amount}, 
      ])
    entity.transactions.create!(attributes)
  end
end
World(TransactionHelpers)