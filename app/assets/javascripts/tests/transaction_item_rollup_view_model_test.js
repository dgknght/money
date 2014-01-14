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
      url: 'transactions/10.json',
      type: 'PUT',
      responseText: []
    });
    $.mockjax({
      url: 'entities/10/transactions.json?account_id=2',
      responseText: [
        {
          id: 10,
          transaction_date: '2014-01-13',
          description: 'Paycheck',
          items: [
            { id: 100, account_id: 1, action: 'debit', amount: 1000, reconciled: true },
            { id: 200, account_id: 2, action: 'credit', amount: 1000, reconciled: false },
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
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
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
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.description(), 'Paycheck', 'should have the correct value.');
      start();
    });
  });
});
asyncTest('otherAccountPath', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.otherAccountPath(), 'Checking', 'should have the correct value.');
      start();
    });
  });
});
asyncTest('reconciled', function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.reconciled(), false, 'should have the correct value.');
      equal(item.otherItem().reconciled(), true, 'should have the correct value.');
      start();
    });
  });
});
asyncTest('amount', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.amount(), 1000, 'should have the correct value.');
      start();
    });
  });
});
asyncTest("polarizedAmount setter", function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      item.polarizedAmount(1001);
      _.each(item.transaction_item.transaction.items(), function(i) {
        equal(i.amount(), 1001, "each item should have the new amount.");
      });
      start();
    });
  });
});
asyncTest("polarizedAmount setter - negative", function() {
  expect(3);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.action(), 'credit', "The action should be credit initially.");

      item.polarizedAmount(-1000);
      equal(item.action(), 'debit', "The action should change to debit when negating the amount.");
      equal(item.otherItem().action(), 'credit', "The action of the other item should also be reversed.");
      start();
    });
  });
});
asyncTest("formattedPolarizedAmount", function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.formattedPolarizedAmount(), "1,000.00", "should have the correct value.");
      start();
    });
  });
});
asyncTest("formattedPolarizedAmount setter", function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      item.formattedPolarizedAmount("123.45");
      equal(item.amount(), 123.45, "should update the underlying amount.");
      start();
    });
  });
});
asyncTest("toggleDetails", function() {
  expect(6);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.details().length, 0, "The details should be empty by default.");
      equal(item.showDetails(), false, "The details should be hidden by default.");
      equal(item.toggleCss(), 'ui-icon-triangle-1-e', "The indicator should point right when details are hidden.");
      item.toggleDetails();
      equal(item.details().length, 2, "The details should not be empty after toggle.");
      equal(item.showDetails(), true, "The details should not be hidden after toggle.");
      equal(item.toggleCss(), 'ui-icon-triangle-1-s', "The indicator should point down when details are displayed.");
      start();
    });
  });
});
asyncTest("formattedBalance", function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.formattedBalance(), "1,000.00", "should have the correct value.");
      start();
    });
  });
});
asyncTest("destroy", function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      ok(item.destroy); //TODO Would like to verify that the ajax method is called correctly
      start();
    });
  });
});
