/*
 * Entity view model
 */
 function EntityViewModel(entity, app) {
  var _self = this;
  this._app = app;
  this.id = ko.observable(entity.id);
  this.name = ko.observable(entity.name).extend({ required: "A name must be specified." });
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

  this.getTransactionItems = function(account, callback) {
    var path = "entities/{entity_id}/transactions.json?account_id={account_id}".format({account_id: account.id(), entity_id: this.id()});
    $.getJSON(path, function(transactions) {
      var transaction_items = transactions.map(function(transaction, index) {
        return new TransactionViewModel(transaction, _self);
      }).map(function(transaction, index) {
        return transaction.items();
      })
      .flatten()
      .where(function(transaction_item) {
        return transaction_item.account_id() == account.id();
      });

      // assign the 'previous' references
      for (var i = 1; i < transaction_items.length; i++) {
        transaction_items[i].previousItem(transaction_items[i-1]);
      }

      callback(transaction_items);
    });
  };
}
EntityViewModel.prototype = new ServiceEntity();
