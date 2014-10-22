/*
 * Represents an item in a reconciliation
 */
function ReconciliationItemViewModel(transaction_item) {
  if (transaction_item == null)
    throw 'Argument cannot be null: transaction_item';

  var _self = this;
  this.transaction_item = transaction_item;
}
