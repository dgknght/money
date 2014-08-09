/*
 * Holding view model
 */
function HoldingViewModel(holding, entity) {
  var _self = this;

  if (entity == null) throw 'entity must have a value';
  this.entity = entity;

  this.id           = ko.observable(holding.id);
  this.commodity_id = ko.observable(holding.commodity_id);

  this._commodity = ko.observable();
  this.commodity = ko.computed(function() {
    if (this._commodity() != null) return this._commodity();
    this.entity.getCommodity(this.commodity_id(), function(commodity) {
      _self._commodity(commodity);
    });
  }, this);

  this.symbol = ko.computed(function() {
    var commodity = this.commodity();
    return commodity == null ? null : commodity.symbol();
  }, this);
}
