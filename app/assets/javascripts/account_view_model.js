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
  this.children = ko.observableArray();
  this.parent_id = ko.observable(account.parent_id);

  this.entityDescription = function() {
    return this.name();
  };
  this.entityIdentifier = function() { return 'account'; };
  this.entityListPath = function() {
    return "entities/{id}/accounts.json".format({ id: _self.entity.id });
  };
  this.entityPath = function() {
    return "accounts/{id}.json".format({ id: _self.id });
  };
  this.onDestroyed = function() {
    _self.entity.accounts.remove(_self);
  };

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

  this.cssClass = ko.computed(function() {
    return "clickable account_depth_{depth}".format({ depth: this.depth() });
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

  this.sameSideAs = function(account) {
    if (this.isLeftSide()) {
      return account.isLeftSide();
    } else {
      return !account.isLeftSide();
    }
  };

  this.inferAction = function(value) {
    if (value < 0)
      return this.isLeftSide() ? CREDIT : DEBIT;
    return this.isLeftSide() ? DEBIT : CREDIT;
  };

  this.display = function() {
    entity.displayAccount(_self);
  };

  this.undisplay = function() {
    entity.undisplayAccount(_self);
  };

  this.insertSucceeded = function() {
    if (this.parent_id() != null) {
      var parent = this.entity.getAccount(this.parent_id());
      if (parent == null) {
        console.log("Unable to find parent account with id=" + this.parent_id());
      } else {
        parent.children.push(this);
      }
    }
    this.entity.accounts.push(this);
  };

  this.transaction_items = ko.lazyObservableArray(function() {
    entity.getTransactionItems(this, function(transaction_items) {
      transaction_items.pushAllTo(_self.transaction_items);
    });
  }, this);

  this.balance = ko.computed(function() {
    if (this.transaction_items.state() == 'new' || typeof this.transaction_items() === "undefined")
      return account.balance * 1;
    
    return this.transaction_items().sum(function(item) { return item.polarizedAmount(); });
  }, this);

  this.balanceWithChildren = ko.computed(function() {
    var result = this.balance();
    $.each(this.children(), function(index, child) {
      result += child.balanceWithChildren();
    });
    return result;
  }, this);
  
  this.formattedBalance = ko.computed(function() {
    return accounting.formatMoney(this.balance());
  }, this);
  
  this.formattedBalanceWithChildren = ko.computed(function() {
    return accounting.formatMoney(this.balanceWithChildren());
  }, this);
  
  this.newTransactionItem = new NewTransactionItemViewModel(this);

  this.saveNewTransaction = function() {
    this.newTransactionItem.save();
  };

  this.canEdit = function() { return true; };

  this.edit = function() {
    _self.entity.editAccount(_self);
  };

  this.canDestroy = function() { return _self.children().length == 0; };

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

  this.toJson = function() {
    return {
        id: this.id,
        account_type: this.account_type(),
        parent_id: this.parent_id(),
        name: this.name()
      };
  };
}

AccountViewModel.prototype = new ServiceEntity();

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
  this.canDestroy = function() { return false; };
  this.destroy = function() {};
  this.canBeParent = function() { return false; }
  this.availableParents = function() { return []; }
}
