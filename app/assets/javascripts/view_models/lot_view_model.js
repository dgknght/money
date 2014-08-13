function LotViewModel(lot) {
  var _self = this;
  this.id         = ko.observable(lot.id);
  this.account_id = ko.observable(lot.account_id);
}
