//= require lib/accounting.min
//= require lib/jquery-ui-1.10.3.custom.min
//= require lib/underscore.js
//= require strings
//= require arrays
//= require util
//= require knockout_extensions.js
//= require underscore_extensions.js
//= require service_entity
//= require view_models/entity_view_model
//= require view_models/account_view_model
//= require view_models/transaction_view_model
//= require view_models/attachment_view_model
//= require view_models/transaction_item_view_model
//= require view_models/transaction_item_rollup_view_model
//= require view_models/notification_view_model.js
//= require view_models/new_transaction_item_view_model.js
//= require view_models/holding_view_model.js
//= require view_models/commodity_view_model.js
//= require view_models/lot_view_model.js

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
  this.editEntity = ko.observable();
  this.editAccount = ko.observable();
  this.editAttachment = ko.observable();
  this.notifications = ko.observableArray();

  this.newEntity = function() {
    var result = new EntityViewModel({ name: "New Entity" }, _self);
    this.entities.push(result);
    this.editEntity(result);
    this.selectedEntity(result);
    return result;
  };

  this.editSelectedEntity = function() {
    _self.editEntity(_self.selectedEntity());
  };

  this.removeSelectedEntity = function(supressConfirmation) {
    supressConfirmation = supressConfirmation && _.isBoolean(supressConfirmation);
    _self.selectedEntity().remove(supressConfirmation);
  };

  this.notify = function(message, type) {
    type = type == null ? 'notice' : type;
    var notification = new NotificationViewModel(type, message);
    this.notifications.push(notification);
    setTimeout(function() { _self.notifications.remove(notification); }, 10000);
  };
  
  // TODO Consider moving this into entity, but need to be able to handle event registration in app.html.haml
  this.displayedAccounts = ko.observableArray();
  this.selectedAccount = ko.computed(function() {
    if (this.displayedAccounts().length == 0 || this.selectedAccountIndex() < 0) return null;
    return this.displayedAccounts()[this.selectedAccountIndex()];
  }, this);
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

  this.getAccountPaths = function(request, callback) {
    var entity = _self.selectedEntity();
    if (entity == null) {
      callback([]);
      return;
    }

    var text = request.term.toLowerCase();
    var result = entity.accounts()
      .map(function(account, index) {
        return account.path();
      })
      .where(function(path) {
        return path.toLowerCase().indexOf(text) >= 0;
      });
    callback(result);
  };

};
