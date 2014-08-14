function LotViewModel(lot) {
  var _self = this;
  this.id           = ko.observable(lot.id);
  this.account_id   = ko.observable(lot.account_id);
  this.commodity_id = ko.observable(lot.commodity_id);
  this.price        = ko.observable(lot.price);
  this.shares_owned = ko.observable(lot.shares_owned);
}
