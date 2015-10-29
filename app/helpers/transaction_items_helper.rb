module TransactionItemsHelper
  def other_account(transaction_item)
    items = transaction_item.transaction.items.select{ |i| i.id != transaction_item.id }

    puts "other items: #{items.map{|i| "#{i.action} #{i.account.name} #{i.amount}"}}"

    items.length == 1 ? items.first.account.name : 'multiple'
  end
end
