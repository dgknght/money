function ReconciliationViewModel(reconciliation) {

  if (reconciliation == null)
    throw "Argument cannot be null: reconciliation";

  var _self = this;
  this.closing_balance = ko.observable(0);
  this.reconciliation_date = ko.observable(new Date());
  this.items = ko.observableArray();

  // read-only properties
  this.previous_balance = reconciliation.previous_balance
    ? accounting.formatNumber(reconciliation.previous_balance)
    : 0;
  var prd = _.ensureDate(reconciliation.previous_reconciliation_date);
  this.previous_reconciliation_date = prd ? prd.toLocaleDateString() : null;


  this.reconciled_balance = ko.computed(function() {
    return _.reduce(this.items(), function(sum, item) {
      return sum + item.transaction_item.polarizedAmount();
    }, 0);
  }, this);

  this.difference = ko.computed(function() {
    return this.closing_balance() - this.reconciled_balance();
  }, this);

  this.formatted_difference = ko.computed(function() {
    return accounting.formatNumber(this.difference());
  }, this);

  this.addTransactionItem = function(transaction_item) {
    var reconciliationItem = new ReconciliationItemViewModel(transaction_item);
    this.items.push(reconciliationItem);
    return reconciliationItem;
  };

  this.formatted_reconciliation_date = ko.computed({
    read: function() {
            return _self.reconciliation_date().toLocaleDateString();
          },
    write: function(value) {
            this.reconciliation_date(new Date(value));
           }
  });
}
