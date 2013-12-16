//= require strings
//= require arrays
//= require knockout_extensions.js
//= require entity_view_model
//= require account_view_model
//= require accounting.min
//= require jquery-ui-1.10.3.custom.min

/*
 * Constructor for the client-side application
 */
function MoneyApp() {
  var _self = this;
  
  this.name = function(){ return 'MoneyApp'; };
  
  this.selectedEntity = ko.observable();
  this.displayedAccounts = ko.observableArray();
  this.selectedAccountIndex = ko.observable();
  this.entities = ko.lazyObservableArray(function() {
    $.getJSON("entities.json", function(entities) {
      $.map(entities, function(entity, index) {
        return new EntityViewModel(entity, _self);
      }).pushAllTo(_self.entities);
    });
  }, this);
  
  this.displayAccount = function(account) {
    var index = this.displayedAccounts().firstIndexOf(function(a) {
      return a.id == account.id;
    });
    if (index == -1) {
      this.displayedAccounts.push(account);
      this.selectedAccountIndex(this.displayedAccounts().length - 1);
    } else {
      this.selectedAccountIndex(index);
    }
  };
  
  this.getTransactionItems = function(account, callback) {
    var path = "entities/{entity_id}/transactions.json?account_id={account_id}".format({account_id: account.id, entity_id: _self.selectedEntity().id});
    $.getJSON(path, function(transactions) {
      var transaction_items = $.map(transactions, function(transaction, index) {
        return transaction.items;
      })
      .flatten()
      .where(function(transaction_item) {
        transaction_item.account_id == account.id;
      });
      callback(transaction_items);
    });
  };
};
