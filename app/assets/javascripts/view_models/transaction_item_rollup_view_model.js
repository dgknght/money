function TransactionItemRollupViewModel(transaction_item, previousItem) {
  var _self = this;

  this.transaction_item = transaction_item;
  this.details = ko.observableArray();
  this.showDetails = ko.observable(false);
  this.previousItem = ko.observable(previousItem);

  this.id = ko.computed(function() {
    return this.transaction_item.id();
  }, this);

  this.action = ko.computed({
    read: function() { return this.transaction_item.action(); },
    write: function(value) { this.transaction_item.action(value); },
    owner: this
  });

  this.attachments = ko.computed(function() {
    return this.transaction_item.transaction.attachments();
  }, this);
  this.hasAttachment = ko.computed(function() {
    return this.transaction_item.transaction.hasAttachment();
  }, this);
  this.hasNoAttachments = ko.computed(function() {
    return this.transaction_item.transaction.hasNoAttachments();
  }, this);
  this.newAttachment = function() {
    this.transaction_item.transaction.newAttachment();
  };
  this.attachmentsVisible = ko.observable(false);
  this.toggleAttachmentsVisible= function() {
    var current = this.attachmentsVisible();
    this.attachmentsVisible(!current);
  };

  this.transaction_date = ko.computed(function() {
    return this.transaction_item.transaction.transaction_date();
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
      var account = this.transaction_item.account();
      if (account == null) throw "Cannot set polarizedAmount unless account_id is set to a valid value.";

      var otherItem = this.otherItem();
      if (otherItem == null)
        throw "Cannot set the amount through TransactionItemRollupViewModel unless there is exactly one other item.";

      // Set the current item
      this.transaction_item.polarizedAmount(value);

      this._updateOtherItemPolarizedAmount();
    },
    owner: this
  }, this);

  this._updateOtherItemPolarizedAmount = function() {
    var value = this.polarizedAmount();
    if (value != null && this.transaction_item.account().sameSideAs(this.otherItem().account()))
      value = 0 - value;
    this.otherItem().polarizedAmount(value);
  };

  this.formattedPolarizedAmount = ko.computed({
    read: function() {
      return accounting.formatNumber(this.polarizedAmount(), 2);
    },
    write: function(value) {
      var amount = parseFloat(value);
      this.polarizedAmount(isNaN(amount) ? null : amount);
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
      var otherItem = this.otherItem();
      if (otherItem == null) {
        console.log("The transaction item cannot be edited in simple mode.");
        return;
      }

      var account = this.transaction_item.transaction.entity.getAccountFromPath(value);
      if (account == null) {
        console.log("Unable to find the account \"" + value + "\".");
        return;
      }

      otherItem.account_id(account.id());

      // Force the polarizedAmount of the other item to be updated, as the polarity might have changed
      this._updateOtherItemPolarizedAmount();
    },
    owner: this
  }, this);

  this.toggleDetails = function() {
    if (this.showDetails()) {
      this.details.removeAll();
      this.showDetails(false);
    } else {
      this.transaction_item.transaction.items().pushAllTo(this.details);
      this.showDetails(true);
    }
  };

  this.toggleCss = ko.computed(function() {
   return this.showDetails() ? "ui-icon-triangle-1-s" : "ui-icon-triangle-1-e";
  }, this);

  this.balance = ko.computed(function() {
    var base = this.previousItem() == null ? 0 : this.previousItem().balance();
    return base + this.polarizedAmount();
  }, this);

  this.formattedBalance = ko.computed(function() {
    return accounting.formatNumber(this.balance(), 2);
  }, this);

  this.destroy = function() {
    this.transaction_item.destroy();
  };

  this.transaction = function() {
    return _self.transaction_item.transaction;
  };

  this.formattedTransactionDate.subscribe(function() { _self.transaction_item.transaction.requestSave(); });
  this.description.subscribe(function() { _self.transaction_item.transaction.requestSave(); });
  this.polarizedAmount.subscribe(function() { _self.transaction_item.transaction.requestSave(); });
  this.otherAccountPath.subscribe(function() { _self.transaction_item.transaction.requestSave(); });
}
