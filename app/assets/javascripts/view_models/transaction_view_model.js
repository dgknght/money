function TransactionViewModel(transaction, entity) {
  var _self = this;
  this.entity = entity;
  this.id = ko.observable(transaction.id);
  this.transaction_date = ko.observable(_.ensureDate(transaction.transaction_date)).extend({ 
    propertyName: 'transaction_date',
    required: "A valid transaction date must be specified.",
    isDate: null
  });
  this.description = ko.observable(transaction.description).extend({
    propertyName: 'description',
    required: "A description must be specified"
  });
  this.allItems = new ko.observableArray().extend({ propertyName: 'items' });
  this.items = new ko.computed(function() {
    return _.filter(this.allItems(), function(i) { return !i.destroyed(); });
  }, this);

  this.formattedTransactionDate = ko.computed({
    read: function() {
      var d = this.transaction_date();
      return (d && d.toLocaleDateString) ? d.toLocaleDateString("en-US", {timeZone: "utc"}) : null;
    },
    write: function(value) {
      var dateValue = new Date(value);
      this.transaction_date(dateValue);
    },
    owner: this
  }, this);

  this._sum = function(action) {
    return _.chain(this.items())
      .filter(function(i) { return i.action() == action; })
      .map(function(i) { return i.amount(); })
      .reduce(function(sum, amount) { return sum + amount; }, 0)
      .value();
  };

  this.debitAmount = ko.computed(function() {
    return this._sum('debit');
  }, this).extend({ propertyName: 'debitAmount' });

  this.formattedDebitAmount = ko.computed(function() {
    return accounting.formatNumber(this.debitAmount(), 2);
  }, this);

  this.creditAmount = ko.computed(function() {
    return this._sum('credit');
  }, this).extend({ propertyName: 'creditAmount', equalTo: _self.debitAmount });

  this.formattedCreditAmount = ko.computed(function() {
    return accounting.formatNumber(this.creditAmount(), 2);
  }, this);

  this.entityDescription = function() {
    return "'{description}' on {date} for {amount}".format({
      date: this.transaction_date().toLocaleDateString(),
      description: this.description(),
      amount: accounting.formatMoney(this.creditAmount())
    });
  };

  this.entityIdentifier = function() {
    return "transaction";
  };

  this.entityListPath = function() {
    return "entities/{entity_id}/transactions.json".format({ entity_id: _self.entity.id() });
  };

  this.onDestroyed = function() {
    $.each(this.items(), function(index, item) {
      item.account().transaction_items.remove(item);
    });
  };

  this.entityPath = function() {
    return "transactions/{id}.json".format({id: this.id()});
  };

  this._saveToken = null;
  this.requestSave = function() {
    if (!this.validate()) {

      console.log("requestSave aborted...model isn't valid.");

      return;
    }

    if (this._saveToken != null) {
      clearTimeout(this._saveToken);
      this._saveToken = null;
    }

    this._saveToken = setTimeout(function() { _self.save(); }, 1000);
  }

  this.toJson = function() {
    return {
      id: this.id(),
      transaction_date: _.toIsoDate(this.transaction_date()),
      description: this.description(),
      items_attributes: this.allItems().map(function(item) { return item.toJson(); })
    };
  };

  this.insertSucceeded = function(data) {
    // update the ID values on the new items
    $.each(data.items, function(index, item) {
      var viewModel = _self.items().first(function(i) { return i.account_id() == item.account_id && i.amount() == item.amount && i.action() == item.action && i.id() == null});
      viewModel.id(item.id);
    });

    // Add the new transaction items to the appropriate accounts
    $.each(_self.items(), function(index, item) {
      item.account().processNewTransactionItem(item);
    });
  };

  this.updateSucceeded = function() {
    this.entity._app.notify("The transaction was updated successfully.", "notice");
  };

  this.updateFailed = function(error) {
    var message = "";
    for (var key in error.errors) {
      message += "<dt>" + key + "</dt>";
      message += "<dd>" + error.errors[key].delimit() + "</dd>";
    }

    message = "Unable to update the transaction. <dl>" + message + "</dl>";
    this.entity._app.notify(message, "error");
  };

  this.addTransactionItem = function() {
    var newItem = new TransactionItemViewModel({}, _self);
    this.allItems.push(newItem);
    return newItem;
  };

  this.validatedProperties = function() {
    return [
      this.description,
      this.transaction_date,
      this.creditAmount
    ]
  };

  this._getTransactionItemViewModel = function(item) {
    var existing = this.entity.getTransactionItem(item.id);
    if (existing) return existing;
    return new TransactionItemViewModel(item, _self);
  };

  var itemViewModels = $.map(transaction.items, function(item, index) {
    return _self._getTransactionItemViewModel(item);
  });
  itemViewModels.pushAllTo(this.allItems);
}

TransactionViewModel.prototype = new ServiceEntity();
