function NewTransactionItemViewModel(account) {
  var _self = this;

  this._account = account;

  this.account_id = ko.observable();

  this.transaction_date = ko.observable(new Date());

  this.description = ko.observable();

  this.amount = ko.observable();

  this.otherAccount = ko.computed(function() {
    if (this.account_id() == null) return null;
    return this._account.entity.accounts().first(function(a) { return a.id == _self.account_id() });
  }, this);

  this.otherAccountPath = ko.computed({
    read: function() {
      var account = this.otherAccount();
      return account == null ? null : account.path();
    }, 
    write: function(value) {
      var account = _self._account.entity.getAccountFromPath(value);
      if (account == null) {
        console.log("Unable to find an account with path \"" + value + "\".");
        return;
      }

      _self.account_id(account.id);
    }
  }, this);

  this.formattedTransactionDate = ko.computed({
    read: function() {
      return this.transaction_date().toLocaleDateString();
    },
    write: function(value) {
      var dateValue = new Date(value);
      this.transaction_date(dateValue);
    }
  }, this);

  this.save = function() {
    // Build the new transaction object graph and save it
    var otherAccount = _self.otherAccount();
    var otherAmount = otherAccount.sameSideAs(_self._account) ? 0 - _self.amount() : _self.amount();
    var transaction = {
      transaction_date: _self.transaction_date(),
      description: _self.description(),
      items: [
        {
          account_id: _self._account.id,
          action: _self._account.inferAction(_self.amount()),
          amount: Math.abs(_self.amount())
        },
        {
          account_id: _self.account_id(),
          action: otherAccount.inferAction(otherAmount),
          amount: Math.abs(otherAmount)
        }
      ]
    };
    var viewModel = new TransactionViewModel(transaction, _self._account.entity);
    viewModel.save();

    // Reset the instance for the next new item
    _self.description(null);
    _self.amount(null);
    _self.account_id(null);
  };
}
