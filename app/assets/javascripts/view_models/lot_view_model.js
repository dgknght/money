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
    if (this._commodity() == null) {
      this.entity.getCommodity(this.commodity_id(), function(commodity) {
        _self._commodity(commodity);
      });
    }
    return this._commodity();
  }, this);

  this.latestPrice = ko.computed(function() {
    if (this.commodity() == null) {
      return null;
    }
    return this.commodity().latestPrice();
  }, this);

  this.workingPrice = ko.computed(function() {
    var latestPrice = this.latestPrice();
    var result = latestPrice ? latestPrice.price() : this.price();
    return result;
  }, this);

  this.currentValue = ko.computed(function() {
    return this.workingPrice() * this.shares_owned();
  }, this);

  this.cost = ko.computed(function() {
    return this.shares_owned() * this.price();
  }, this);

  this.updateAttributes = function(data) {
    this.shares_owned(_.ensureNumber(data.shares_owned));
  };
}
