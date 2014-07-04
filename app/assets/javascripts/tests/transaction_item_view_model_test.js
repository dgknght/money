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
      url: 'transactions/*/attachments.json',
      responseText: [
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
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 101 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 10001, function(item) {
      ok(_.isNumber(item.transaction_item.amount() + 1), "The amount should be a number");
      start();
    });
  });
});
asyncTest("accountPath", function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 101 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 10001, function(item) {
      var transactionItem = item.transaction_item;
      ok(transactionItem.accountPath, "The object should have an accountPath property accessor");
      if (transactionItem.accountPath)
        equal(transactionItem.accountPath(), "Checking", "The property should have the correct value.");
      start();
    });
  });
});
asyncTest("remove", function() {
  expect(4);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 101 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 10001, function(item) {
      var transaction = item.transaction_item.transaction;
      item.transaction_item.remove();
      equal(1, transaction.items().length, "The number of items in the transaction should decrease by one after remove.");
      
      var isAbsent = _.every(transaction.items(), function(i) { return i.id() != item.id()});
      ok(isAbsent, "The item should not longer be in the transaction after remove.");

      equal(transaction.debitAmount(), 0, "The debit amount on the transaction should reflect the removed item.");

      var expected = { 
        id: 1001, 
        transaction_date: '2014-01-01', 
        description: 'Salary',
        items_attributes: [
          { id: 10001, account_id: 101, action: 'debit', amount: 0, _destroy: 1 },
          { id: 10002, account_id: 102, action: 'credit', amount: 1000 }
        ]
      };
      deepEqual(transaction.toJson(), expected, "The serialized transaction should reflect the removed item.");

      start();
    });
  });
});
