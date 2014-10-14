function ReconciliationViewModel(reconciliation) {
  this.previous_balance = ko.observable(reconciliation.previous_balance);
  this.closing_balance = ko.observable(0);
  this.reconciliation_date = ko.observable(new Date());
}
