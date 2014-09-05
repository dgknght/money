/*
 * Account view model
 */
function AccountViewModel(account, entity) {
  var CREDIT = 'credit';
  var DEBIT = 'debit';

  var COMMODITIES_CONTENT_TYPE = 'commodities';
  var COMMODITY_CONTENT_TYPE = 'commodity';
  var CURRENCY_CONTENT_TYPE = 'currency';
  var CONTENT_TYPES = [COMMODITIES_CONTENT_TYPE, COMMODITY_CONTENT_TYPE, CURRENCY_CONTENT_TYPE];

  var _self = this;
  this.entity = entity;
  this.id = ko.observable(account.id);
  this.name = ko.observable(account.name).extend({ required: "Name is a required field." });
  this.account_type = ko.observable(account.account_type).extend({
    required: "Account type is a required field.",
    includedIn: ['asset', 'liability', 'equity', 'income', 'expense']
  });
  this.content_type = ko.observable(account.content_type).extend({
    required: "Content type is a required field.",
    includedIn: CONTENT_TYPES
  });
  this._balance = ko.observable(account.balance * 1);
  this.children = ko.observableArray();
  this.parent_id = ko.observable(account.parent_id);

  this.entityDescription = function() {
    return this.name();
  };
  this.entityIdentifier = function() { return 'account'; };
  this.entityListPath = function() {
    return "entities/{id}/accounts.json".format({ id: _self.entity.id() });
  };
  this.entityPath = function() {
    return "accounts/{id}.json".format({ id: _self.id() });
  };
  this.onDestroyed = function() {
    _self.entity.accounts.remove(_self);
  };

  this.commoditiesMenuVisible = ko.computed(function() {
    return this.content_type() == COMMODITIES_CONTENT_TYPE;
  }, this);

  this._transactionItemsVisible = ko.observable(!this.commoditiesMenuVisible());

  this.transactionItemsVisible = ko.computed({
    read: function() {
      return this._transactionItemsVisible();
    },
    write: function(value) {
      if (this.content_type() != COMMODITIES_CONTENT_TYPE) {
        return;
      }
      this._transactionItemsVisible(value);
    },
    owner: this
  });

  this.showTransactionItems = function() {
    _self.transactionItemsVisible(true);
  };

  this.holdingsVisible = ko.computed({
    read: function() {
      return !this.transactionItemsVisible();
    },
    write: function(value) {
      this.transactionItemsVisible(!value);
    },
    owner: this
  });

  this.showHoldings = function() {
    _self.holdingsVisible(true);
  };

  this.lots = ko.lazyObservableArray(function() {
    this.getLots(function(lots) {
      _.map(lots, function(lot) { return new LotViewModel(lot, _self.entity); })
        .pushAllTo(_self.lots);
    });
  }, this);

  this.getLots = function(callback) {
    if (this.id() == null) return [];

    var path = "accounts/{id}/lots.json".format({id: this.id()});
    $.getJSON(path, callback);
  };

  this.sumOfLotValues = ko.computed(function() {
    return _.reduce(this.lots(), function(sum, lot) { return sum + lot.currentValue(); }, 0);
  }, this);

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
    if (value == null)
      return null;
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
      var lastItem = null;
      var viewModels = _.map(transaction_items, function(item) {
        var result = new TransactionItemRollupViewModel(item);
        if (lastItem) lastItem.previousItem(result)
        lastItem = result;
        return result;
      });
      viewModels.pushAllTo(_self.transaction_items);
    });
  }, this);

  this.balance = ko.computed(function() {
    if (this.transaction_items.state() == 'new' || typeof this.transaction_items() === "undefined")
      return this._balance();
    
    return this.transaction_items().sum(function(item) { return item.polarizedAmount(); });
  }, this);

  this.formattedBalance = ko.computed(function() {
    return accounting.formatMoney(this.balance());
  }, this);

  this._withChildren = function(methodName) {
    return _.reduce(this.children(), function(sum, c) { return sum + c[methodName + "WithChildren"](); }, this[methodName]());
  };

  this.balanceWithChildren = ko.computed(function() {
    return this._withChildren("balance");
  }, this);
  
  this.formattedBalanceWithChildren = ko.computed(function() {
    return accounting.formatMoney(this.balanceWithChildren());
  }, this);
  
  this.value = ko.computed(function() {
    return (this.content_type() == COMMODITY_CONTENT_TYPE)
      ? this.sumOfLotValues()
      : this.balance();
  }, this);

  this.formattedValue = ko.computed(function() {
    return accounting.formatNumber(this.value(), 2);
  }, this);

  this.valueWithChildren = ko.computed(function() {
    return this._withChildren("value");
  }, this);

  this.formattedValueWithChildren = ko.computed(function() {
    return accounting.formatNumber(this.valueWithChildren(), 2);
  }, this);

  this.cost = ko.computed(function() {
    if (this.content_type() == COMMODITY_CONTENT_TYPE)
      return _.reduce(this.lots(), function(sum, l) { return sum + l.cost(); }, 0);
    return this.balance();
  }, this);

  this.formattedCost = ko.computed(function() {
    return accounting.formatNumber(this.cost(), 2);
  }, this);

  this.costWithChildren = ko.computed(function() {
    return _.reduce(this.children(), function(sum, c) { return sum + c.costWithChildren(); }, this.cost());
  }, this);

  this.formattedCostWithChildren = ko.computed(function() {
    return accounting.formatNumber(this.costWithChildren(), 2);
  }, this);

  this.shares = ko.computed(function() {
    return _.reduce(this.lots(), function(sum, l) { return sum + l.shares_owned(); }, 0);
  }, this);

  this.formattedShares = ko.computed(function() {
    return accounting.formatNumber(this.shares(), 4);
  }, this);
  
  this.gainLoss = ko.computed(function() {

    console.log(this.name() + " value " + this.value() + " - cost " + this.cost() + " = " + (this.value() - this.cost()));

    return this.value() - this.cost();
  }, this);

  this.formattedGainLoss = ko.computed(function() {
    return accounting.formatNumber(this.gainLoss(), 2);
  }, this);

  this.gainLossWithChildren = ko.computed(function() {

    console.log(this.name() + " gainLoss=" + this.gainLoss());

    return _.reduce(this.children(), function(sum, child) {

      console.log(child.name() + " gainLoss=" + child.gainLoss());

      return sum + child.gainLoss();
    }, this.gainLoss());
  }, this);

  this.formattedGainLossWithChildren = ko.computed(function() {
    return accounting.formatNumber(this.gainLossWithChildren(), 2);
  }, this);

  this.childrenValue = ko.computed(function() {
    return _.reduce(this.children(), function(sum, c) { return sum + c.value(); }, 0);
  }, this);

  this.formattedChildrenValue = ko.computed(function() {
    return accounting.formatNumber(this.childrenValue(), 2);
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
      return account.canBeParent() && account.id() != _self.id();
    });
  }, this);

  this._serverPath = function() {
    return "accounts/{id}.json".format({ id: _self.id() });
  };

  this.reload = function(callback) {
    callback = callback == null ? function(){} : callback;

    if (this.id() == null) {
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
        id: this.id(),
        account_type: this.account_type(),
        parent_id: this.parent_id(),
        name: this.name()
      };
  };

  this.validatedProperties = function() {
    return [
      this.name,
      this.account_type
    ];
  };

  this.processNewTransactionItem = function(item) {
    if (this.transaction_items.state() == 'new') {
      // If the transaction items haven't been loaded, just adjust the balance
      this._balance(this._balance() + item.polarizedAmount());
      return;
    }

    var rollup = new TransactionItemRollupViewModel(item);

    // Calculate the position for the new item in the list
    var index = _.sortedIndexDesc(this.transaction_items(), rollup, function(item) {
      return item.transaction_item.transaction.transaction_date();
    });

    // update the linked list that calculates the running balance
    // & update the observable array
    if (index < this.transaction_items().length) {
      this.transaction_items()[index].insert(rollup);
      this.transaction_items.splice(index, 0, rollup);
    } else {
      var last = this.transaction_items().last();
      if (last)
        this.transaction_items().last().previousItem(rollup);
      this.transaction_items.push(rollup);
    }
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
