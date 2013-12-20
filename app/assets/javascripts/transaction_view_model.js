function TransactionViewModel(transaction, entity) {
  var _self = this;
  this.entity = entity;
  this.id = transaction.id;
  this.transaction_date = ko.observable(new Date(transaction.transaction_date));
  this.description = ko.observable(transaction.description);
  this.items = new ko.observableArray();

  this.creditAmount = ko.computed(function() {
    return this.items().where(function(item) {
      return item.action() == 'credit';
    }).sum(function(item) {
      return item.amount();
    });
  }, this);

  this.entityDescription = function() {
    console.log("creditAmount=" + this.creditAmount());

    return "'{description}' on {date} for {amount}".format({
      date: this.transaction_date().toLocaleDateString(),
      description: this.description(),
      amount: accounting.formatMoney(this.creditAmount())
    });
  };

  this.onDestroyed = function() {
    $.each(this.items(), function(index, item) {
      item.account().transaction_items.remove(item);
    });
  };

  this.entityPath = function() {
    return "transactions/{id}.json".format({id: this.id});
  };

  var itemViewModels = $.map(transaction.items, function(item, index) {
      return new TransactionItemViewModel(item, _self);
  });
  itemViewModels.pushAllTo(this.items);
}

TransactionViewModel.prototype = new ServiceEntity();
