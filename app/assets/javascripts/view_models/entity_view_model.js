/*
 * Entity view model
 */
 function EntityViewModel(entity, app) {
  var _self = this;
  this._app = app;
  this.id = ko.observable(entity.id);
  this.name = ko.observable(entity.name).extend({ required: "A name must be specified." });
  this.transactions = ko.observableArray();
  this.validatedProperties = function() {
    return [
      this.name
    ]
  };
  this.accounts = ko.lazyObservableArray(function() {
    var path = "entities/{id}/accounts.json".format({id: this.id()});
    $.getJSON(path, function(accounts) {
      var viewModels = $.map(accounts, function(account, index) {
        return new AccountViewModel(account, _self);
      });
      $.each(viewModels, function(index, viewModel) {
        viewModels
          .where(function(m) { return m.parent_id() == viewModel.id() })
          .pushAllTo(viewModel.children);
      });
      viewModels.pushAllTo(_self.accounts);
    });
  }, this);

  this.groupedAccounts = ko.computed(function() {
    var accounts = this.accounts()
    accounts.sort(function(a, b) { return a.path().compareTo(b.path()); });
    var grouped = accounts.groupBy(function(account) {
      return account.account_type();
    });
    
    var types = ["Asset", "Liability", "Equity", "Income", "Expense"];
    var result = new Array();
    for (var i = 0; i < types.length; i++) {
      var type = types[i];
      var key = type.toLowerCase();
      var groupViewModel = new AccountGroupViewModel(type, grouped[key]);
      result.push(groupViewModel);
      if (grouped[key] != null)
        grouped[key].pushAllTo(result);
    }
    return result;
  }, this);
  
  this.newAccount = function() {
    var viewModel = new AccountViewModel({ name: 'New account'}, _self);
    _self._app.editAccount(viewModel);
  };

  this.displayAccount = function(account) {
    this._app.displayAccount(account);
  };

  this.undisplayAccount = function(account) {
    this._app.undisplayAccount(account);
  };

  this.getAccount = function(account_id) {
    return this.accounts().first(function(a) {
      return a.id() == account_id;
    });
  };

  this.getAccountFromPath = function(path) {
    return this.accounts().first(function(a) {
      return a.path() == path;
    });
  };

  this.editAccount = function(account) {
    this._app.editAccount(account);
  };

  this._transactionAccountsSearched = {};
  this.getTransactionItems = function(account, callback) {
    // Look in the local cache first
    if (this._transactionAccountsSearched[account.id()]) {
      var result = this._getItemsByAccountId(account.id());
      callback(result);
      return;
    }

    // Load from the server if necessary
    var path = "entities/{entity_id}/transactions.json?account_id={account_id}".format({account_id: account.id(), entity_id: this.id()});
    $.getJSON(path, function(transactions) {
      var viewModels = _.map(transactions, function(t) { return new TransactionViewModel(t, _self); });
      viewModels.pushAllTo(_self.transactions);

      var result = _self._getItemsByAccountId(account.id(), viewModels);
      _self._transactionAccountsSearched[account.id()] = true;
      callback(result);
    });
  };

  this._getItemsByAccountId = function(account_id, transactions) {
    return _.chain(transactions || _self.transactions())
      .map(function(t) { return t.items(); })
      .flatten()
      .filter(function(item) { return item.account_id() == account_id; })
      .value();
  };
}
EntityViewModel.prototype = new ServiceEntity();
