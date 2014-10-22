function ReconciliationViewModel(reconciliation) {

  if (reconciliation == null)
    throw "Argument cannot be null: reconciliation";

  this.previous_balance = ko.observable(reconciliation.previous_balance);
  this.previous_reconciliation_date = ko.observable(_.ensureDate(reconciliation.previous_reconciliation_date));
  this.closing_balance = ko.observable(0);
  this.reconciliation_date = ko.observable(new Date());
  this.items = ko.observableArray();
  this.reconciled_balance = ko.computed(function() {
    return _.reduce(this.items(), function(sum, item) {
      return sum + item.transaction_item.polarizedAmount();
    }, 0);
  }, this);

  this.addTransactionItem = function(transaction_item) {
    var reconciliationItem = new ReconciliationItemViewModel(transaction_item);
    this.items.push(reconciliationItem);
    return reconciliationItem;
  };
}
