function TransactionItemRollupViewModel(transaction_item) {
  this.transaction_item = transaction_item;

  this.id = ko.computed(function() {
    return this.transaction_item.id();
  }, this);

  this.action = ko.computed({
    read: function() { return this.transaction_item.action(); },
    write: function(value) { this.transaction_item.action(value); },
    owner: this
  });

  this.amount= ko.computed({
    read: function() {
      return this.transaction_item.amount();
    },
    write: function(value) {
      this.transaction_item.amount(value);
    },
    owner: this
  }, this);

  this.formattedTransactionDate = ko.computed({
    read: function() {
      return this.transaction_item.transaction.formattedTransactionDate();
    },
    write: function(value) {
      this.transaction_item.transaction.formattedTransactionDate(value);
    },
    owner: this
  }, this);

  this.description = ko.computed({
    read: function() {
      return this.transaction_item.transaction.description();
    },
    write: function(value) {
      this.transaction_item.transaction.description(value);
    },
    owner: this
  }, this);

  this.reconciled = ko.computed(function() {
    return this.transaction_item.reconciled();
  }, this);

  this.polarizedAmount = ko.computed({
    read: function() {
      return this.transaction_item.polarizedAmount();
    },
    write: function(value) {
      var otherItem = this.otherItem();
      if (otherItem == null)
        throw "Cannot set the amount through TransactionItemRollupViewModel unless there is exactly one other item.";

      if (value != null && this.transaction_item.account().sameSideAs(otherItem.account()))
        value = 0 - value;
      otherItem.polarizedAmount(value || 0);

      this.transaction_item.polarizedAmount(value);
    },
    owner: this
  }, this);

  this.otherItem = ko.computed(function() {
    var self = this;
    var otherItems = this.transaction_item.transaction.items().where(function(item) {
      return item.id() != self.id();
    });

    return otherItems.length == 1
      ? otherItems.first()
      : null;
  }, this);

  this.otherAccountPath = ko.computed({
    read: function() {
      var otherItem = this.otherItem();
      var account = otherItem == null ? null : otherItem.account();
      return account == null ? "[multiple]" : account.path();
    },
    write: function(value) {
      var account = this.transaction.entity.getAccountFromPath(value);
      if (account == null) {
        console.log("Unable to find the account \"" + value + "\".");
        return;
      }

      var otherItem = this.otherItem();
      if (otherItem == null) {
        console.log("The transaction item cannot be edited in simple mode.");
        return;
      }

      otherItem.account_id(account.id);
    },
    owner: this
  }, this);

}
