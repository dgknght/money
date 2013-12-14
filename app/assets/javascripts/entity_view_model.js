/*
 * Entity view model
 */
 function EntityViewModel(entity, app) {
  var _self = this;
  this._app = app;
  this.id = entity.id;
  this.name = ko.observable(entity.name);
  this.accounts = ko.lazyObservableArray(function() {
    var path = "entities/{id}/accounts.json".format({id: this.id});
    $.getJSON(path, function(accounts) {
      var viewModels = $.map(accounts, function(account, index) {
        return new AccountViewModel(account, _self);
      });
      $.each(viewModels, function(index, viewModel) {
        viewModels
          .where(function(m) { return m.parent_id() == viewModel.id })
          .pushAllTo(viewModel.children);
      });
      var grouped = viewModels.groupBy(function(account) {
        return account.account_type();
      });
      
      var types = ["Asset", "Liability", "Equity", "Income", "Expense"];
      for (var i = 0; i < types.length; i++) {
        var type = types[i];
        var key = type.toLowerCase();
        var groupViewModel = new AccountGroupViewModel(type, grouped[key]);
        _self.accounts.push(groupViewModel);
        $.each(grouped[key], function(index, entity) {
          _self.accounts.push(entity);
        });
      }
    });
  }, this);
}