function ReconciliationViewModel(reconciliation, account) {

  if (reconciliation == null)
    throw "Argument cannot be null: reconciliation";

  var _self = this;
  this.account = account;
  this.closing_balance = ko.observable(0);
  this.reconciliation_date = ko.observable(new Date());

  this.items = ko.observableArray(
    _.chain(account.transaction_items())
      .filter(function(i) { return !i.reconciled(); })
      .map(function(i) { return new ReconciliationItemViewModel(i); })
      .value()
    );

  this.debit_items = ko.computed(function() {
    return _.filter(this.items(), function(i) { return i.action() == "debit"; });
  }, this);

  this.credit_items = ko.computed(function() {
    return _.filter(this.items(), function(i) { return i.action() == "credit"; });
  }, this);

  // read-only properties
  this.previous_balance = _.ensureNumber(reconciliation.previous_balance);
  this.formatted_previous_balance = this.previous_balance
    ? accounting.formatNumber(this.previous_balance)
    : 0;
  var prd = _.ensureDate(reconciliation.previous_reconciliation_date);
  this.previous_reconciliation_date = prd ? prd.toLocaleDateString() : null;

  // computed properties
  this.formatted_closing_balance = ko.computed({
    read: function() {
            return accounting.formatNumber(_self.closing_balance());
          },
    write: function(value) {
             _self.closing_balance(_.ensureNumber(value));
           }
  });

  this.reconciled_balance = ko.computed(function() {
    return _.chain(this.items())
      .filter(function(i) { return i.selected(); })
      .reduce(function(sum, i) { return sum + i.amount(); }, _self.previous_balance)
      .value();
  }, this);


  this.formatted_reconciliation_date = ko.computed({
    read: function() {
            return _self.reconciliation_date().toLocaleDateString();
          },
    write: function(value) {
            this.reconciliation_date(new Date(value));
           }
  });
  this.formatted_reconciled_balance = ko.computed(function() {
    return accounting.formatNumber(this.reconciled_balance());
  }, this);

  this.difference = ko.computed(function() {
    return this.closing_balance() - this.reconciled_balance();
  }, this);

  this.formatted_difference = ko.computed(function() {
    return accounting.formatNumber(this.difference(), 2);
  }, this);

  this.formatted_reconciliation_date = ko.computed({
    read: function() {
            return _self.reconciliation_date().toLocaleDateString();
          },
    write: function(value) {
            this.reconciliation_date(new Date(value));
           }
  });

  this.valid = ko.computed(function() {
    return this.difference() == 0;
  }, this);

  // methods
  this.addTransactionItem = function(transaction_item) {
    var reconciliationItem = new ReconciliationItemViewModel(transaction_item);
    this.items.push(reconciliationItem);
    return reconciliationItem;
  };

  this.cancel = function() {
    console.log("cancel");
  };

  this.submit = function() {
    console.log("submit");
  };
}
