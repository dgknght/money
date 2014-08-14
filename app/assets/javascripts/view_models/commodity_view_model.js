/*
 * Commodity view model
 */
function CommodityViewModel(commodity) {
  var _self = this;

  this.id = ko.observable(commodity.id);
  this.symbol = ko.observable(commodity.symbol);
  this.name = ko.observable(commodity.name);
  this.market = ko.observable(commodity.market);
  this.prices = ko.lazyObservableArray(function() {
    this._getPrices(function(prices) {
      var viewModels = _.map(prices, function(p) { return new PriceViewModel(p, _self); });
      viewModels.pushAllTo(_self.prices);
    });
  }, this);

  this._getPrices = function(callback) {
    var path = "commodities/{id}/prices.json".format({id: this.id()});
    $.getJSON(path, callback);
  };

  this.latestPrice = ko.computed(function() {
    if (this.prices.state == 'new') {
      this.prices();
      return null;
    } else if (this.prices.state == 'loading') {
      return null;
    } else {
      // the list should be maintained in descending date order
      return this.prices().last();
    }
  }, this);
}
