//= require strings
//= require arrays
//= require knockout_extensions.js

/*
 * Entity view model
 */
 function EntityViewModel(entity, app) {
  var _self = this;
  this._app = app;
  this.id = entity.id;
  this.name = ko.observable(entity.name);
}

/*
 * Constructor for the client-side application
 */
function MoneyApp() {
  var _self = this;
  
  this.name = function(){ return 'MoneyApp'; };
  
  this.selectedEntity = ko.observable({name: 'Loading...', accounts: []});
  this.displayedAccounts = ko.observableArray();
  this.selectedAccountIndex = ko.observable();
  this.getTransaction = function(transaction_id) {
    return null;
  };
  this.entities = ko.lazyObservableArray(function() {
  
    console.log("loadEntities");
    
    var self = this
    $.getJSON("entities.json", function(entities) {
      for (var i = 0; i < entities.length; i++) {
        var entity = entities[i];
        var viewModel = new EntityViewModel(entity, self);
        self.entities.push(viewModel);
      }
    });
  }, this);
};

/*
 * Window functions
 */
function showTransactions(account) {
  var index = firstIndexOf(app.displayedAccounts(), function(a) {
    return a.id == account.id;
  });
  if (index == -1) {
    // HACK this code depends on the name given to the variable that holds the MoneyApp instance in the HTML page and needs to be fixed
    app.displayedAccounts.push(account);
    app.selectedAccountIndex(app.displayedAccounts().length - 1);
  } else {
    app.selectedAccountIndex(index);
  }
}