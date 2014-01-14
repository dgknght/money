function TransactionItemViewModel(transaction_item, transaction) {
  this.id = ko.observable(transaction_item.id);
  this.transaction = transaction;
  this.account_id = ko.observable(transaction_item.account_id).extend({
    required: "A valid account must be specified.",
    propertyName: 'account_id'
  });
  this.action = ko.observable(transaction_item.action).extend({
    propertyName: 'action'
  });
  this.amount = ko.observable(transaction_item.amount).extend({
    required: "An amount must be specified.",
    numeric: "The amount must be a valid number.",
    propertyName: 'amount'
  });
  this.reconciled = ko.observable(transaction_item.reconciled);

  this._saveId = null;

  this.account = ko.computed(function() {
    return this.transaction.entity.getAccount(this.account_id());
  }, this);

  this.accountName = ko.computed(function() {
    var account = this.account();
    return account == null ? null : account.name();
  }, this);

  this.formattedAmount = ko.computed(function() {
    return accounting.formatNumber(this.amount(), 2);
  }, this);

  this.polarizedAmount = ko.computed({
    read: function() {
      var account = this.account();
      var polarity = account == null ? 1 : account.polarity(this.action());
      return polarity * this.amount();
    },
    write: function(value) {
      var account = this.account();
      if (account == null) throw "Cannot set polarizedAmount unless the account_id is set to a valid value.";

      this.action(account.inferAction(value));
      this.amount(value == null ? null : Math.abs(value));
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

  this.destroy = function() {
    this.transaction.destroy();
  };

  this.toJson = function() {
    return {
      id: this.id(),
      action: this.action(),
      amount: this.amount(),
      account_id: this.account_id()
    };
  };

  // TODO This is all duplicated from service entity...need to consolodate it
  this.validate = function() {
    return _.every(this.validatedProperties(), function(prop) { return !prop.hasError(); });
  };

  this.validatedProperties = function() {
    return [
      this.account_id,
      this.amount
    ];
  };

  this.errorMessages = function() {
    return _.chain(this.validatedProperties())
      .map(function(prop) { return _.map((_.isArray(prop) ? prop : [prop]), function(p){ return p.errorMessages(); }); })
      .flatten();
  };
}
