/*
 * Commodity view model
 */
function CommodityViewModel(commodity) {
  this.id = ko.observable(commodity.id);

  this.symbol = ko.observable(commodity.symbol);
  this.name = ko.observable(commodity.name);
  this.market = ko.observable(commodity.market);
}
