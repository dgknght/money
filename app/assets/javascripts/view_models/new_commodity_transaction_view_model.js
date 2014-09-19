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
}
