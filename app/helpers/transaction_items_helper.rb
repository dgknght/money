module TransactionItemsHelper
  def other_account(transaction_item)
    items = transaction_item.owning_transaction.items.select{ |i| i.id != transaction_item.id }
    items.length == 1 ? items.first.account.name : 'multiple'
  end
end
