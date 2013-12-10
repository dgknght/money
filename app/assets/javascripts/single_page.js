/*
 * String extension methods
 */
String.prototype.format = function(args) {
  return this.replace(/{([^{}]*)}/, function (fullMatch, subMatch) {
    var value = args[subMatch];
    return (typeof value === 'string' || typeof value === 'number') ? value : fullMatch;
  });
};

/*
 * Array extension methods
 */
Array.prototype.delimit = function(delimitor) {
  var result = "";
  var first = true;
  delimitor = delimitor || ",";
  $.each(this, function(index, value) {
    if (first)
      first = false;
    else
      result += delimitor;
    result += value
  });
  return result;
};
Array.prototype.groupBy = function(getKey) {
  var result = new Object();
  for (var i = 0; i < this.length; i++) {
    var value = this[i];
    var key = getKey(value);
    
    var list = result[key];
    if (list == null) {
      list = new Array();
      result[key] = list;
    }
    list.push(value);
  }
  return result;
};

Array.prototype.pushAll = function(values) {
  $.each(values, function(index, value) { this.push(value); });
};

Array.prototype.pushAllTo = function(target) {
  if (target.push === 'undefined')
    throw "The target \"" + target + "\" must be an array.";
  $.each(this, function(index, value){ target.push(value); });
};

Array.prototype.sum = function(getValue) {
  var result = 0;
  $.each(this, function(index, value) { result += getValue(value); });
  return result;
}

Array.prototype.where = function(predicate) {
  var result = new Array();
  for (var i = 0; i < this.length; i++) {
    var value = this[i];
    if (predicate(value))
      result.push(value)
  }
  return result;
};


/*
 * Account view model
 */
function AccountViewModel(account) {
  var self = this;
  this.id = account.id;
  this.parent_id = account.parent_id;
  this.element_id = "account_" + this.id;
  this.account_type = ko.observable(account.account_type);
  this.name = ko.observable(account.name);
  this.balance = ko.observable(new Number(account.balance));
  this.cssClass = "account_list_item account_depth_" + account.depth;
  this.children = ko.observableArray();
  this.transaction_items = ko.observableArray();
  
  this.balanceWithChildren = ko.computed(function() {
    var result = this.balance();
    $.each(this.children(), function(index, child){ result += child.balanceWithChildren(); });
    return result;
  }, this);
  this.formattedBalanceWithChildren = ko.computed(function() {
    return accounting.formatMoney(this.balanceWithChildren());
  }, this);
  
  this._transactionItemsLoaded = false;
  this.ensureTransactionItemsLoaded = function() {
    if (self._transactionItemsLoaded) return;

    $.getJSON("accounts/" + self.id + "/transaction_items", function(transaction_items) {
      var previous = null;
      $.each(transaction_items, function(index, transaction_item) {
        var viewModel = new TransactionItemViewModel(transaction_item, previous);
        self.transaction_items.push(viewModel);
        previous = viewModel;
      });
    });
    self._transactionItemsLoaded = true;
  };
}

function AccountCategoryViewModel(type, accountViewModels) {
  this.name = type;
  this.cssClass = "account_category";
  this.accountViewModels = ko.observableArray(accountViewModels);
  
  this.balanceWithChildren = ko.computed(function() {
    var result = 0;
    $.each(this.accountViewModels(), function(index, account){ result += account.balanceWithChildren(); });
    return result;
  }, this);
  this.formattedBalanceWithChildren = ko.computed(function() {
    return accounting.formatMoney(this.balanceWithChildren());
  }, this);
}

function TransactionItemViewModel(transaction_item, previous_item) {
  this.amount = ko.observable(parseFloat(transaction_item.amount));
  this.reconciled = ko.observable(transaction_item.reconciled);
  this.previous_item = ko.observable(previous_item);
  
  this.formattedAmount = ko.computed(function() {
    return accounting.formatNumber(this.amount(), 2);
  }, this);
  this.balance = ko.computed(function() {
    var previousBalance = this.previous_item() == null ? 0 : this.previous_item().balance();
    return previousBalance + this.amount();
  }, this);
  this.formattedBalance = ko.computed(function() {
    return accounting.formatNumber(this.balance(), 2);
  }, this);
  this.formattedReconciled = ko.computed(function() {
    return this.reconciled() ? "X" : "";
  }, this);
}

/*
 * Constructor for the client-side application
 */
function MoneyApp() {
  var _self = this;
  this.selectedEntity.subscribe(function(entity) {
    _self.loadAccounts(entity);
  });
  this.displayedAccounts.subscribe(function(accounts) {
    $.each(accounts, function(i, account) { account.ensureTransactionItemsLoaded(); });
  });
  $.getJSON("entities.json", function(entities) {
    _self.loadEntities(entities); 
  });
};

/*
 * Prototype for the client-side application
 */
MoneyApp.prototype = {
  entities: ko.observableArray(),
  selectedEntity: ko.observable(),
  accounts: ko.observableArray(),
  displayedAccounts: ko.observableArray(),
  loadAccountList: function(allAccounts) {
    // Convert to view models
    var allViewModels = $.map(allAccounts, function(a, i){ return new AccountViewModel(a); });

    // Add children under their parent
    $.each(allViewModels, function(i, parent) {
      var children = allViewModels.where(function(child){ return child.parent_id == parent.id; });
      if (children.length != 0) {
        children.pushAllTo(parent.children);
      }
    });
    
    // Group by type
    var grouped = allViewModels.groupBy(function(a) { return a.account_type(); });
    var types = ["Asset", "Liability", "Equity", "Income", "Expense"];
    for (var i = 0; i < types.length; i++ ) {
      var type = types[i];
      var key = type.toLowerCase();
      var group = grouped[key];
      var topLevelAccounts = group.where(function(account){ return account.parent_id == null; });
      this.accounts.push(new AccountCategoryViewModel(type, topLevelAccounts));
      if (group != null) group.pushAllTo(this.accounts);
    }
  },
  loadAccounts: function (entity) {
    this.accounts.removeAll()
    if (entity == null) return;
    
    var path = "entities/{id}/accounts.json".format({ id: entity.id });
    var self = this;
    $.getJSON(path, function(accounts) {
      self.loadAccountList(accounts);
    });
  },
  loadEntities: function (entities) {
    for (var i = 0; i < entities.length; i++) {
      this.entities.push(entities[i]);
    }
  }
}

/*
 * Window functions
 */
function showTransactions(account) {
  app.displayedAccounts.push(account);
}