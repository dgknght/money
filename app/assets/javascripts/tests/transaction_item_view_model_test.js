module('TransactionItemViewModel', {
  setup: function() {
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: 10, name: 'First Entity' }
      ]
    });
    $.mockjax({
      url: 'entities/10/accounts.json',
      responseText: [
        { id: 101, name: 'Checking', account_type: 'asset' },
        { id: 102, name: 'Salary', account_type: 'income' }
      ]
    });
    $.mockjax({
      url: 'entities/10/transactions.json?account_id=101',
      responseText: [
        { 
          id: 1001, 
          transaction_date: '2014-01-01',
          description: 'Salary',
          items: [
            { id: 10001, account_id: 101, action: 'debit', amount: "1000" },
            { id: 10002, account_id: 102, action: 'credit', amount: "1000" }
          ]
        },
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest("amount", function() {
  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 101 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 10001, function(item) {
      ok(_.isNumber(item.transaction_item.amount() + 1), "The amount should be a number");
      start();
    });
  });
});
