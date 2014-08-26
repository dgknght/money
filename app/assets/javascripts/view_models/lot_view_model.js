function LotViewModel(lot, entity) {
  var _self = this;

  this.entity = entity;
  this.id           = ko.observable(lot.id);
  this.account_id   = ko.observable(lot.account_id);
  this.commodity_id = ko.observable(lot.commodity_id);
  this.price        = ko.observable(_.ensureNumber(lot.price));
  this.shares_owned = ko.observable(_.ensureNumber(lot.shares_owned));

  this._commodity = ko.observable();
  this.commodity = ko.computed(function() {
    if (this._commodity() != null) {
      return this._commodity();
    }
    this.entity.getCommodity(this.commodity_id(), function(commodity) {
      _self._commodity(commodity);
    });
  }, this);

  this.latestPrice = ko.computed(function() {
    if (this.commodity() == null) {
      return null;
    }
    return this.commodity().latestPrice();
  }, this);

  this.workingPrice = ko.computed(function() {
    var latestPrice = this.latestPrice();
    return latestPrice ? latestPrice.price() : this.price();
  }, this);

  this.currentValue = ko.computed(function() {
    return this.workingPrice() * this.shares_owned();
  }, this);
}
