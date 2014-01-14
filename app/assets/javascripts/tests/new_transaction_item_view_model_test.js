module('NewTransactionItemViewModel', {
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
        { id: 101, name: 'Checking', account_type: 'asset', balance: 0 },
        { id: 102, name: 'Dining', account_type: 'expense', balance: 0 }
      ]
    });
    $.mockjax({
      url: 'entities/10/transactions.json?account_id=102',
      responseText: []
    });
    $.mockjax({
      url: 'entities/10/transactions.json',
      type: 'POST',
      responseText: {
        id: 1000,
        transaction_date: '2014-01-01',
        description: 'Mooyah',
        items: [
          { id: 10000, account_id: 102, action: 'debit', amount: 5 },
          { id: 10001, account_id: 101, action: 'credit', amount: 5 }
        ]
      }
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest('formattedTransactionDate', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 102 }, function(account) {
    equal(account.newTransactionItem.formattedTransactionDate(), new Date().toLocaleDateString(), "It should default to today's date.");
    start();
  });
});
asyncTest('description', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 102 }, function(account) {
    ok(account.newTransactionItem.description);
    start();
  });
});
asyncTest('otherAccountPath', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 102 }, function(account) {
    ok(account.newTransactionItem.otherAccountPath);
    start();
  });
});
asyncTest('amount', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 102 }, function(account) {
    ok(account.newTransactionItem.amount);
    start();
  });
});
asyncTest('save balance', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 102 }, function(account) {
    account.newTransactionItem.formattedTransactionDate('1/1/2014');
    account.newTransactionItem.description('Mooyah');
    account.newTransactionItem.otherAccountPath('Checking');
    account.newTransactionItem.amount(5);

    account.balance.subscribe(function(newBalance) {
      equal(newBalance, 5, "The account balance should be updated.");

      start();
    });

    account.newTransactionItem.save();
  });
});
asyncTest('save transaction_items', function() {
  expect(3);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 102 }, function(account) {
    account.newTransactionItem.formattedTransactionDate('1/1/2014');
    account.newTransactionItem.description('Mooyah');
    account.newTransactionItem.otherAccountPath('Checking');
    account.newTransactionItem.amount(5);

    account.transaction_items();

    account.transaction_items.subscribe(function(items) {
      var item = _.last(items);
      equal(item.amount(), 5, "The amount property should have the correct value.");
      equal(item.action(), 'debit', "The action property should have the correct value.");
      equal(item.balance(), 5, "The balance property should have the correct value.");

      start();
    });

    account.newTransactionItem.save();
  });
});
