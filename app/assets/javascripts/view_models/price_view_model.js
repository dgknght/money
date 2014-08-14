/*
 * Price view model
 */
function PriceViewModel(price, commodity) {
  var _self = this;

  this.id         = ko.observable(price.id);
  this.trade_date = ko.observable(_.ensureDate(price.trade_date));
  this.price      = ko.observable(price.price);
  this.commodity  = commodity;
}
