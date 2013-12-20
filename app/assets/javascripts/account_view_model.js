/*
 * Account view model
 */
function AccountViewModel(account, entity) {
  var CREDIT = 'credit';
  var DEBIT = 'debit';

  var _self = this;
  this.entity = entity;
  this.id = account.id
  this.name = ko.observable(account.name);
  this.account_type = ko.observable(account.account_type);
  this.balance = ko.observable(account.balance * 1);
  this.children = ko.observableArray();
  this.depth = ko.observable(account.depth);
  this.parent_id = ko.observable(account.parent_id);
  
  this.balanceWithChildren = ko.computed(function() {
    var result = this.balance();
    $.each(this.children(), function(index, child) {
      result += child.balanceWithChildren();
    });
    return result;
  }, this);
  
  this.cssClass = ko.computed(function() {
    return "clickable account_depth_{depth}".format({ depth: this.depth() });
  }, this);
  
  this.formattedBalance = ko.computed(function() {
    return accounting.formatMoney(this.balance());
  }, this);
  
  this.formattedBalanceWithChildren = ko.computed(function() {
    return accounting.formatMoney(this.balanceWithChildren());
  }, this);
  
  this.isLeftSide = function() {
    return this.account_type() == 'asset' || this.account_type() == 'expense';
  };

  this.isRightSide = function() {
    return !this.isLeftSide();
  };

  this.polarity = function(action) {
    if ((action == CREDIT && this.isLeftSide()) || (action == DEBIT && this.isRightSide()))
      return -1;
    return 1;
  };

  this.display = function() {
    entity.displayAccount(_self);
  };

  this.undisplay = function() {
    entity.undisplayAccount(_self);
  };

  this.transaction_items = ko.lazyObservableArray(function() {
    entity.getTransactionItems(this, function(transaction_items) {
      transaction_items.pushAllTo(_self.transaction_items);
    });
  }, this);

  this.canEdit = function() { return true; };
  this.edit = function() {
    _self.entity.editAccount(_self);
  };
  this.canBeParent = function() { return true; }

  this.availableParents = ko.computed(function() {
    return this.entity.accounts().where(function(account) {
      return account.canBeParent() && account.id != _self.id;
    });
  }, this);

  this.reload = function(callback) {
    var path = "accounts/{id}.json".format({ id: _self.id });
    $.getJSON(path, function(data) {
      _self.name(data.name);
      _self.parent_id(data.parent_id);
      _self.account_type(data.account_type);
      if (callback != null)
        callback();
    });
  };

  this.save = function(callback) {
    console.log("save " + _self.name());
    if (callback != null)
      callback();
  };
}

/*
 * View model that wraps a group of accounts of the same type
 */
function AccountGroupViewModel(name, accounts) {
  this.name = ko.observable(name);
  this.accounts = ko.observableArray(accounts);
  this.cssClass = "account_category";
  
  this.balanceWithChildren = ko.computed(function() {
    var children = this.accounts().where(function(account) {
      return account.parent_id() == null;
    });
    
    return children.sum(function(a) { return a.balanceWithChildren(); });
  }, this);
  
  this.display = function() {};
  
  this.formattedBalanceWithChildren = ko.computed(function() {
    return accounting.formatMoney(this.balanceWithChildren());
  }, this);

  this.canEdit = function() { return false; };
  this.edit = function() {};
  this.canBeParent = function() { return false; }
  this.availableParents = function() { return []; }
}
