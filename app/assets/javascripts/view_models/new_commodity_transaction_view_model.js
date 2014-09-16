/**
 * Manages the creation of new commodity transactions
 */
function NewCommodityTransactionViewModel(account) {
  var _self = this;
  this._account = account;

  this.action = ko.observable('buy');
  this.transaction_date = ko.observable(new Date());
}
