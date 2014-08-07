/*
 * Holding view model
 */
function HoldingViewModel(holding, entity) {
  var _self = this;
  this.entity = entity;

  this.id = ko.observable(holding.id);

  this.symbol = ko.computed(function() {
    var commodity = this.commodity();
    return commodity == null ? null : commodity.symbol();
  }, this);

  this.commodity = ko.computed(function() {
    if (this._commodity != null) return this._commodity;

    this.entity.getCommodity(this.commodity_id(), function(commodity) {
      _self.commodity(commodity);
    });
  }, this);
}
