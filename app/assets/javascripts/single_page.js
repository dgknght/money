//= require lib/accounting.min
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
//= require view_models/commodity_view_model.js
//= require view_models/lot_view_model.js
//= require view_models/price_view_model.js
//= require view_models/new_commodity_transaction_view_model.js
//= require view_models/reconciliation_view_model.js
//= require view_models/reconciliation_item_view_model.js

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

      // select the entity based on the current cookie
      var workingEntity = null;
      var cookie_id = /entity_id=(\d+)/.exec(document.cookie);
      if (cookie_id) {
        cookie_id = parseInt(cookie_id[1]);
        workingEntity = _.find(_self.entities(), function(e) {
          return e.id() == cookie_id;
        });
      }
      if (workingEntity == null) workingEntity = _.first(_self.entities());
      _self.selectedEntity(workingEntity);
      if (_self.selectedEntity())
        _self._registerEntity(_self.selectedEntity());


      // listed for changes so we can update the cookie
      _self.selectedEntity.subscribe(_self._registerEntity);
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

  this._registerEntity = function(entity) {
    // handle null or new entity
    if (entity == null || entity.id() == null) {
      if (entity && entity.id() == null) {
        var s = entity.id.subscribe(function(id) {
          _self._registerEntity(entity);
          s.dispose();
        });
      }
      return;
    }

    // Set a cookie to remember the selected entity
    var id = entity.id();
    if (id) {
      document.cookie = "entity_id=" + id;

      // replace the links in the navigation
      $('#ajax_nav ul li a').each(function() {
        this.href = this.href.replace(/entities\/\d*/, "entities/" + id);
      });
    }
  }

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

  this.getCommoditySymbols = function(request, callback) {
    var entity = _self.selectedEntity();
    if (entity == null) {
      callback([]);
      return;
    }

    var text = request.term.toUpperCase();
    var result = _.chain(entity.commodities())
      .map(function(c) { return c.symbol(); })
      .filter(function(s) { return s.toUpperCase().indexOf(text) >= 0; })
      .value();
    callback(result);
  };

};
