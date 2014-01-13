module('TransactionItemRollupViewModel', {
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
        { id: 1, name: 'Checking', account_type: 'asset' },
        { id: 2, name: 'Salary', account_type: 'income' },
        { id: 3, name: 'Income Tax', account_type: 'expense' }
      ]
    });
    $.mockjax({
      url: 'entities/10/transactions.json?account_id=2',
      responseText: [
        {
          id: 10,
          transaction_date: '2014-01-13',
          description: 'Paycheck',
          items: [
            { id: 100, account_id: 1, action: 'debit', amount: 1000 },
            { id: 200, account_id: 2, action: 'credit', amount: 1000 },
          ]
        },
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest('formattedTransactionDate', function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 2, function(item) {
      equal(item.formattedTransactionDate(), '1/13/2014', 'should have the correct value.');

      item.formattedTransactionDate('1/1/2014');
      var transaction = account.entity.transactions().first();

      var expected = new Date('1/1/2014');
      equal(transaction.transaction_date() + "", expected + "", "setter should update the underlying transaction");

      start();
    });
  });
});
asyncTest('description', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 2, function(item) {
      equal(item.description(), 'Paycheck', 'should have the correct value.');
      start();
    });
  });
});
asyncTest('otherAccountPath', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 2, function(item) {
      equal(item.otherAccountPath(), 'Checking', 'should have the correct value.');
      start();
    });
  });
});
asyncTest('amount', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 2, function(item) {
      equal(item.amount(), 1000, 'should have the correct value.');
      start();
    });
  });
});
asyncTest("polarizedAmount setter", function() {
  expect(2);

  var app = new MoneyApp();
  var transactionItem = getTransactionItem(app, {entity_id: 10, account_id: 1, transaction_item_id: 1}, function(transactionItem) {
    transactionItem.polarizedAmount(1001);
    _.each(transactionItem.transaction.items(), function(item) {
      equal(item.amount(), 1001, "each item should have the new amount.");
    });
    start();
  });
})
asyncTest("polarizedAmount setter - negative", function() {
  expect(2);

  var app = new MoneyApp();
  var transactionItem = getTransactionItem(app, {entity_id: 10, account_id: 1, transaction_item_id: 100}, function(transactionItem) {
    transactionItem.polarizedAmount(-1000);
    equal(transactionItem.action(), 'credit');
    equal(transactionItem.otherItem().action(), 'debit');
    start();
  });
})
