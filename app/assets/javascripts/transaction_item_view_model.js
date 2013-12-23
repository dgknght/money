function TransactionItemViewModel(transaction_item, transaction) {
  this.id = transaction_item.id;
  this.transaction = transaction;
  this.account_id = ko.observable(transaction_item.account_id);
  this.action = ko.observable(transaction_item.action);
  this.amount = ko.observable(transaction_item.amount);
  this.reconciled = ko.observable(transaction_item.reconciled);
  this.previousItem = ko.observable();
  this.showDetails = ko.observable(false);

  this.toggleDetails = function() {
    if (this.showDetails()) {
      this.details.removeAll();
      this.showDetails(false);
    } else {
      this.transaction.items().pushAllTo(this.details);
      this.showDetails(true);
    }
  };

  this.toggleCss = ko.computed(function() {
   return this.showDetails() ? "ui-icon-triangle-1-s" : "ui-icon-triangle-1-e";
  }, this);

  this.details = ko.observableArray();

  this.account = ko.computed(function() {
    return this.transaction.entity.getAccount(this.account_id());
  }, this);

  this.accountName = ko.computed(function() {
    return this.account().name();
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

  this.creditAmount = ko.computed({
    read: function() {
      return this.action() == 'credit' ? this.amount() : 0;
    },
    write: function(value) {
      if (value != 0) {
        this.amount(value);
        this.action('credit');
      }
    },
    owner: this
  });

  this.formattedCreditAmount = ko.computed({
    read: function() {
      var value = this.creditAmount();
      return value == 0 ? "" : accounting.formatNumber(value, 2);
    },
    write: function(value) {
      if (value == null || value.length == 0) {
        this.creditAmount(0);
      } else {
        this.creditAmount(parseFloat(value));
      }
    },
    owner: this
  });

  this.debitAmount = ko.computed({
    read: function() {
      return this.action() == 'debit' ? this.amount() : 0;
    },
    write: function(value) {
      if (value != 0) {
        this.amount(value);
        this.action('debit');
      }
    },
    owner: this
  });

  this.formattedDebitAmount = ko.computed({
    read: function() {
      var value = this.debitAmount();
      return value == 0 ? "" : accounting.formatNumber(value, 2);
    },
    write: function(value) {
      if (value == null || value.length == 0) {
        this.debitAmount(0);
      } else {
        this.debitAmount(parseFloat(value));
      }
    },
    owner: this
  });

  this.balance = ko.computed(function() {
    var base = this.previousItem() == null ? 0 : this.previousItem().balance();
    return base + this.polarizedAmount();
  }, this);

  this.formattedBalance = ko.computed(function() {
    return accounting.formatNumber(this.balance(), 2);
  }, this);

  this.formattedTransactionDate = ko.computed(function() {
    return this.transaction.transaction_date().toLocaleDateString();
  }, this);

  this.description = ko.computed(function() {
    return this.transaction.description();
  }, this);

  this.otherAccountName = ko.computed(function() {
    var self = this;
    var otherItems = this.transaction.items().where(function(item) {
      return item.id != self.id;
    });

    return otherItems.length == 1
      ? otherItems.first().account().name()
      : "[multiple]";
  }, this);

  this.destroy = function() {
    this.transaction.destroy();
  };
}
