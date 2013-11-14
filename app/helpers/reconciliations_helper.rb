module ReconciliationsHelper
  def is_selected(transaction_item, reconciliation)
    reconciliation.items.select{ |i| i.transaction_item_id == transaction_item.id}.any?
  end
end
