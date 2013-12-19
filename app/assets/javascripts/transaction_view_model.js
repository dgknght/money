function TransactionViewModel(transaction, entity) {
  var _self = this;
  this.entity = entity;
  this.id = transaction.id;
  this.transaction_date = ko.observable(new Date(transaction.transaction_date));
  this.description = ko.observable(transaction.description);
  this.items = new ko.observableArray($.map(transaction.items, function(item, index) { return new TransactionItemViewModel(item, _self); }));
}
