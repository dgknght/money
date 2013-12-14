/*
 * Account view model
 */
function AccountViewModel(account, app) {
  var _self = this;
  this._app = app;
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
  
  this.display = function() {
    app.displayAccount(_self);
  };
}

/*
 * View model that wraps a group of accounts of the same type
 */
function AccountGroupViewModel(name, accounts) {
  this.name = name;
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
}