function TransactionItemViewModel(transaction_item, transaction) {
  this.id = transaction_item.id;
  this.transaction = transaction;
  this.account_id = ko.observable(transaction_item.account_id);
  this.action = ko.observable(transaction_item.action);
  this.amount = ko.observable(transaction_item.amount);
  this.reconciled = ko.observable(transaction_item.reconciled);
  this.previousItem = ko.observable();
  this.showDetails = ko.observable(false);

  this._saveId = null;

  this.amount.subscribe(function(a) {
    this.transaction.requestSave();
  }, this);

  this.account_id.subscribe(function(id) {
    this.transaction.requestSave();
  }, this);

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

  this.polarizedAmount = ko.computed({
    read: function() {
      return this.account().polarity(this.action()) * this.amount();
    },
    write: function(value) {
      if (value == this.polarizedAmount()) return;

      this.action(this.account().inferAction(value));
      this.amount(Math.abs(value));

      var otherItem = this.otherItem();
      if (this.account().sameSideAs(otherItem.account()))
        value = 0 - value;
      this.otherItem().polarizedAmount(value);
    },
    owner: this
  });

  this.formattedPolarizedAmount = ko.computed({
    read: function() {
      return accounting.formatNumber(this.polarizedAmount(), 2);
    },
    write: function(value) {
      var number = accounting.unformat(value);
      this.polarizedAmount(isNaN(number) ? 0 : number);
    },
    owner: this
  });

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

  this.formattedTransactionDate = ko.computed({
    read: function() {
      return this.transaction.transaction_date().toLocaleDateString();
    },
    write: function(value) {
      var dateValue = new Date(value);
      this.transaction.transaction_date(dateValue);
    },
    owner: this
  }, this);

  this.description = ko.computed({
    read: function() {
      return this.transaction.description();
    }, 
    write: function(value) {
      this.transaction.description(value);
    },
    owner: this
  }, this);

  this.otherItem = ko.computed(function() {
    var self = this;
    var otherItems = this.transaction.items().where(function(item) {
      return item.id != self.id;
    });

    return otherItems.length == 1
      ? otherItems.first()
      : null;
  }, this);

  this.otherAccountName = ko.computed(function() {
    var otherItem = this.otherItem();
    return otherItem == null ? "[multiple]" : otherItem.account().name();
  }, this);

  this.otherAccountPath = ko.computed({
    read: function() {
      var otherItem = this.otherItem();
      return otherItem == null ? "[multiple]" : otherItem.account().path();
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

  this.destroy = function() {
    this.transaction.destroy();
  };

  this.toJson = function() {
    return {
      id: this.id,
      action: this.action(),
      amount: this.amount(),
      account_id: this.account_id()
    };
  }
}
