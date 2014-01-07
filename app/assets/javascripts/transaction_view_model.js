function TransactionViewModel(transaction, entity) {
  var _self = this;
  this.entity = entity;
  this.id = transaction.id;
  this.transaction_date = ko.observable(new Date(transaction.transaction_date)).extend({ required: "A valid transaction date must be specified." });
  this.description = ko.observable(transaction.description).extend({ required: "A description must be specified" });
  this.items = new ko.observableArray();

  this.creditAmount = ko.computed(function() {
    return this.items().where(function(item) {
      return item.action() == 'credit';
    }).sum(function(item) {
      return item.amount();
    });
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
    return "entities/{entity_id}/transactions.json".format({ entity_id: _self.entity.id });
  };

  this.onDestroyed = function() {
    $.each(this.items(), function(index, item) {
      item.account().transaction_items.remove(item);
    });
  };

  this.entityPath = function() {
    return "transactions/{id}.json".format({id: this.id});
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

    this._saveToken = setTimeout(function() { console.log('executing the requested save'); _self.save(); }, 1000);
  }

  this.toJson = function() {
    return {
      id: this.id,
      transaction_date: this.transaction_date(),
      description: this.description(),
      items_attributes: this.items().map(function(item) { return item.toJson(); })
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
      if (item.account().transaction_items.state() != 'new') {
        item.account().transaction_items.push(item);
      }
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

  this.transaction_date.subscribe(function(value) {
    this.requestSave();
  }, this);
  this.description.subscribe(function(value) {
    this.requestSave();
  }, this);

  this.validatedProperties = function() {
    return [
      this.description,
      this.transaction_date,
      this.items()
    ]
  };

  var itemViewModels = $.map(transaction.items, function(item, index) {
      return new TransactionItemViewModel(item, _self);
  });
  itemViewModels.pushAllTo(this.items);
}

TransactionViewModel.prototype = new ServiceEntity();
