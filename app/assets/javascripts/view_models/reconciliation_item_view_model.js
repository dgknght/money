/*
 * Represents an item in a reconciliation
 */
function ReconciliationItemViewModel(transaction_item) {
  if (transaction_item == null)
    throw 'Argument cannot be null: transaction_item';

  var _self = this;
  this.transaction_item = transaction_item;

  this.action = ko.computed(function() {
    return this.transaction_item.action();
  }, this);

  this.formatted_transaction_date = ko.computed(function() {
    return this.transaction_item.transaction().formattedTransactionDate();
  }, this);

  this.description = ko.computed(function() {
    return this.transaction_item.transaction().description();
  }, this);

  this.formatted_amount = ko.computed(function() {
    return this.transaction_item.formattedPolarizedAmount();
  }, this);

  this.selected = ko.observable(false);
}
