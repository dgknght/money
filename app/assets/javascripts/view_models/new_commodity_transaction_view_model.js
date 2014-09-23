/**
 * Manages the creation of new commodity transactions
 */
function NewCommodityTransactionViewModel(account) {
  var _self = this;
  this._account = account;

  this.action = ko.observable('buy').extend({ required: "You must select an action.", includedIn: ['buy', 'sell']  });
  this.transaction_date = ko.observable(new Date());
  this.symbol = ko.observable().extend({ required: "You must enter a valid commodity symbol." });
  this.shares = ko.observable().extend({ required: "You must enter a valid number of shares.", numeric: '"Shares" must be a valid number.' });
  this.value = ko.observable().extend({ required: "You must enter a valid numeric 'value'.", numeric: '"Value" must be a valid number.' });

  this.formattedTransactionDate = ko.computed({
    read: function() {
      return _self.transaction_date() ?  _self.transaction_date().toLocaleDateString() : null;
    },
    write: function(value) {
      var dateValue = new Date(value);
      if (!isNaN(dateValue))
        _self.transaction_date(dateValue);
    }
  });

  this.price = ko.computed(function() {
    if (this.value() && this.shares())
      return this.value() / this.shares();
    return null;
  }, this);

  this.validate = function() {
    var props = [_self.action, _self.transaction_date, _self.symbol, _self.shares, _self.value];
    return _.every(props, function(prop) { return prop.hasError == null || !prop.hasError(); });
  };

  this.reset = function() {
    this.symbol(null);
    this.shares(null);
    this.value(null);
  };

  this.save = function(success, error, complete) {
    success = _.ensureFunction(success);
    error = _.ensureFunction(error);
    complete = _.ensureFunction(complete);
    $.ajax({
      url: _self._postUrl(),
      type: 'POST',
      dataType: 'json',
      data: _self._postData(),
      success: function(data) {
        _self._account.lots.refresh();
        _self.reset();
        success(data);
      },
      error: function(jqXHR, textStatus, errorThrown) {
        error(errorThrown);
      },
      complete: complete
    });
  };

  this._postUrl = function() {
    return "accounts/{id}/create_purchase.json".format({ id: _self._account.id() });
  };

  this._postData = function() {
    return {
      purchase: {
        transaction_date: _self.transaction_date().toISOString(),
        action: _self.action(),
        symbol: _self.symbol(),
        shares: _self.shares(),
        value: _self.value()
      }
    };
  };
}
