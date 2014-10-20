function ReconciliationViewModel(reconciliation) {

  if (reconciliation == null)
    throw "Argument cannot be null: reconciliation";

  this.previous_balance = ko.observable(reconciliation.previous_balance);
  this.closing_balance = ko.observable(0);
  this.reconciliation_date = ko.observable(new Date());
}
