/*
 * Holding view model
 */
function HoldingViewModel(holding, entity) {
  var _self = this;

  if (entity == null) throw 'entity must have a value';
  this.entity = entity;

  this.id           = ko.observable(holding.id);
  this.lots         = ko.observableArray(_.map(holding.lots, function(lot) {
    return new LotViewModel(lot);
  }));

  this._commodity = ko.observable();

  this.commodity_id = ko.computed(function() {
    var firstLot = _.first(this.lots());
    return firstLot ? firstLot.commodity_id() : null;
  }, this);
  this.commodity = ko.computed(function() {
    if (this._commodity() != null) return this._commodity();
    this.entity.getCommodity(this.commodity_id(), function(commodity) {
      _self._commodity(commodity);
    });
  }, this);

  this.symbol = ko.computed(function() {
    var commodity = this._commodity();
    return commodity == null ? null : commodity.symbol();
  }, this);

  this.latestPrice = function() {
    var commodity = this.commodity();
    if (commodity) {
      var latestPrice = commodity.latestPrice();
      if (latestPrice) {
        return latestPrice.price();
      }
    }
    return 0;
  };

  this.shares = ko.computed(function() {
    return this.lots().sum(function(lot) { return lot.shares_owned();});
  }, this);

  this.value = ko.computed(function() {
    return this.shares() * this.latestPrice();
  }, this);

  this.cost = ko.computed(function() {
    return this.lots().sum(function(lot) { return lot.price() * lot.shares_owned(); });
  }, this);

  this.gain_loss = ko.computed(function() {
    return this.value() - this.cost();
  }, this);
}
