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
  this.parent_id = ko.observable(account.parent_id);
  this.parent = ko.computed(function() {
    if (this.parent_id() == null) return null;
    return this.entity.getAccount(this.parent_id());
  }, this);

  this.path = ko.computed(function() {
    var parent = this.parent();
    var prefix = parent == null ? "" : parent.path() + "/";
    var result = prefix + this.name();
    return result;
  }, this);
  
  this.depth = ko.computed(function() {
    var parent = this.parent();
    if (parent == null) return 0;
    return parent.depth() + 1;
  }, this);

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

  this._serverPath = function() {
    return "accounts/{id}.json".format({ id: _self.id });
  };

  this.reload = function(callback) {
    callback = callback == null ? function(){} : callback;

    if (this.id == null) {
      callback();
      return;
    }

    $.getJSON(this._serverPath(), function(data) {
      _self.name(data.name);
      _self.parent_id(data.parent_id);
      _self.account_type(data.account_type);

      if (callback != null)
        callback();
    });
  };

  this.save = function(callback) {
    callback = callback == null ? function(){} : callback;
    if (this.id == null) {
      this._insert(callback);
    } else {
      this._update(callback);
    }
  };

  this._insert = function(callback) {
    var path = "entities/{id}/accounts.json".format({ id: _self.entity.id });
    $.ajax({
      url: path,
      accepts: 'json',
      type: 'POST',
      dataType: 'json',
      data: { account: this._toJson() },
      success: function(data) {
        _self.id = data.id;

        // Add the new account to it's parent, if a parent was specified
        if (_self.parent_id() != null) {
          var parent = _self.entity.getAccount(_self.parent_id());
          if (parent == null) {
            console.log("Unable to find parent account with id=" + _self.parent_id);
          } else {
            parent.children.push(_self);
          }
        }

        // Add the new account to the entity
        _self.entity.accounts.push(_self);
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log("*** ERROR ***");
        console.log("textStatus=" + textStatus);
        console.log("errorThrown=" + errorThrown);
        console.log("jqXHR.responseText=" + jqXHR.responseText);
      },
      complete: function(jqXHR, textStatus) {
        callback();
      }
    });
  };

  this._update= function(callback) {
    $.ajax({
      url: this._serverPath(),
      type: 'PUT',
      dataType: 'json',
      data: { account: this._toJson() },
      success: function() {
        // TODO if the parent change, we'll need to move the account to the new parent
      },
      complete: function(jqXHR, textStatus) {
        callback();
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log("*** ERROR ***");
        console.log("textStatus=" + textStatus);
        console.log("errorThrown=" + errorThrown);
        console.log("jqXHR.responseText=" + jqXHR.responseText);
      }
    });
  };

  this._toJson = function() {
    return {
        id: this.id,
        account_type: this.account_type(),
        parent_id: this.parent_id(),
        name: this.name()
      };
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
