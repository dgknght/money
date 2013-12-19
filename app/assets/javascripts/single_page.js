//= require strings
//= require arrays
//= require knockout_extensions.js
//= require entity_view_model
//= require account_view_model
//= require transaction_view_model
//= require transaction_item_view_model
//= require accounting.min
//= require jquery-ui-1.10.3.custom.min

/*
 * Constructor for the client-side application
 */
function MoneyApp() {
  var _self = this;
  
  this.name = function(){ return 'MoneyApp'; };
  
  this.selectedEntity = ko.observable();
  this.selectedAccountIndex = ko.observable();
  this.entities = ko.lazyObservableArray(function() {
    $.getJSON("entities.json", function(entities) {
      $.map(entities, function(entity, index) {
        return new EntityViewModel(entity, _self);
      }).pushAllTo(_self.entities);
    });
  }, this);
  this.accountTypes = ko.observableArray(['asset', 'liability', 'equity', 'income', 'expense']);
  this.editAccount = ko.observable();
  
  // TODO Consider moving this into entity, but need to be able to handle event registration in app.html.haml
  this.displayedAccounts = ko.observableArray();
  this.displayAccount = function(account) {
    var index = this.displayedAccounts().firstIndexOf(function(a) {
      return a.id == account.id;
    });
    if (index == -1) {
      this.displayedAccounts.push(account);
      index = this.displayedAccounts().length - 1;
    }
    this.selectedAccountIndex(index);
  };

  this.undisplayAccount = function(account) {
    var index = this.displayedAccounts().firstIndexOf(function(a) {
      return a.id == account.id;
    });
    if (index != -1) {
      this.displayedAccounts.splice(index, 1);
    }
  };

};
