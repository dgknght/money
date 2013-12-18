function TransactionItemViewModel(transaction_item, transaction) {
  this.id = transaction_item.id;
  this.transaction = transaction;
  this.account_id = ko.observable(transaction_item.account_id);
  this.action = ko.observable(transaction_item.action);
  this.amount = ko.observable(transaction_item.amount);
  this.previousItem = ko.observable();

  this.account = ko.computed(function() {
    return this.transaction.entity.getAccount(this.account_id());
  }, this);

  this.formattedAmount = ko.computed(function() {
    return accounting.formatNumber(this.amount(), 2);
  }, this);

  this.polarizedAmount = ko.computed(function() {
    return this.account().polarity(this.action()) * this.amount();
  }, this);

  this.formattedPolarizedAmount = ko.computed(function() {
    return accounting.formatNumber(this.polarizedAmount(), 2);
  }, this);

  this.balance = ko.computed(function() {
    var base = this.previousItem() == null ? 0 : this.previousItem().balance();
    return base + this.polarizedAmount();
  }, this);

  this.formattedBalance = ko.computed(function() {
    return accounting.formatNumber(this.balance(), 2);
  }, this);
}
