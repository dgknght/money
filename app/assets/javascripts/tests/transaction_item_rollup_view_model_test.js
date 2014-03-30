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
        { id: 3, name: 'Income Tax', account_type: 'expense' },
        { id: 4, name: 'Credit Card', account_type: 'liability' },
        { id: 5, name: 'Dining', account_type: 'expense' }
      ]
    });
    $.mockjax({
      url: 'transactions/*.json',
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
            { id: 200, account_id: 2, action: 'credit', amount: 1000, reconciled: false }
          ]
        }
      ]
    });
    $.mockjax({
      url: 'entities/10/transactions.json?account_id=5',
      responseText: [
        {
          id: 11,
          transaction_date: '2014-01-14',
          description: 'Mooyah',
          items: [
            { id: 101, account_id: 5, action: 'debit', amount: 19, reconciled: true },
            { id: 202, account_id: 4, action: 'credit', amount: 19, reconciled: false }
          ]
        }
      ]
    });
    $.mockjax({
      url: 'transactions/10/attachments.json',
      responseText: [
        { id: 1001, transaction_id: 10, name: 'Paystub', content_type: 'image/png' }
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
asyncTest('formattedPolarizedAmount', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 2 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 200, function(item) {
      equal(item.formattedPolarizedAmount(), '1,000.00', 'should have the correct value.');
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
asyncTest("polarizedAmount setter - expense and liability accounts", function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 5 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 101, function(item) {
      item.polarizedAmount(33);
      equal(item.otherItem().polarizedAmount(), 33, "Setting a positive amount on the expense side should result in a positive value on the liability side.");
      ok(item.transaction_item.transaction.validate(), "The transaction should be in a valid state after the adjustment.");
      start();
    });
  });
});
asyncTest("otherAccountPath setter - expense and asset accounts", function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: 10, account_id: 5 }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', 101, function(item) {
      item.otherAccountPath("Checking");
      equal(item.otherItem().polarizedAmount(), -19, "Setting a positive amount on the expense side should result in a negative value on the asset side.");
      ok(item.transaction_item.transaction.validate(), "The transaction should be in a valid state after the adjustment.");
      start();
    });
  });
});
//asyncTest("polarizedAmount setter - other account without transaction items loaded", function() {
//  expect(2);
//
//  var app = new MoneyApp();
//  getAccount(app, { entity_id: 10, account_id: 2 }, function(salary) {
//    var checking = app.entities().first().accounts().first(function(a) { return a.id() == 1; });
//    getFromLazyLoadedCollection(salary, 'transaction_items', 200, function(item) {
//      checking.balance.subscribe(function(balance) {
//        equal(balance, 1001, "The balance of the other account should update to reflect the change.");
//        start();
//      });
//
//      item.polarizedAmount(1001);
//    });
//  });
//});
//asyncTest("polarizedAmount setter - other account with transaction items loaded", function() {
//  expect(2);
//
//  ok(false, 'need to write the test.');
//});
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
      equal(item.transaction_item.amount(), 123.45, "should update the underlying amount.");
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
  var ids = {
    entity_id: 10,
    account_id: 2,
    transaction_item_id: 200
  };
  getTransactionItemRollup(app, ids, function(item) {
    equal(item.formattedBalance(), "1,000.00", "should have the correct value.");
    start();
  });
});
asyncTest("destroy", function() {
  expect(1);

  var app = new MoneyApp();
  var ids = {
    entity_id: 10,
    account_id: 2,
    transaction_item_id: 200
  };
  getTransactionItemRollup(app, ids, function(item) {
    ok(item.destroy); //TODO Would like to verify that the ajax method is called correctly
    start();
  });
});
asyncTest("hasAttachment", function() {
  expect(3);

  var app = new MoneyApp();
  var ids = {
    entity_id: 10,
    account_id: 2,
    transaction_item_id: 200
  };
  getTransactionItemRollup(app, ids, function(item) {
    ok(item.hasAttachment, "should be a property on the object");
    item.hasAttachment.subscribe(function(hasAttachment) {
      ok(hasAttachment, "should be true if the transaction has an attachment");
      start();
    });
    ok(item.hasAttachment() == false, "should be false until the attachments are loaded");
  });
});
asyncTest("toggleAttachmentsVisible", function() {
  expect(3);

  var app = new MoneyApp();
  var ids = {
    entity_id: 10,
    account_id: 2,
    transaction_item_id: 200
  };
  getTransactionItemRollup(app, ids, function(item) {
    ok(item.toggleAttachmentsVisible, "should be a method on the object");
    if (item.toggleAttachmentsVisible) {
      item.toggleAttachmentsVisible();
      equal(true, item.attachmentsVisible(), "should cause the value of 'attachmentsVisible' to change.");
      item.toggleAttachmentsVisible();
      equal(false, item.attachmentsVisible(), "should cause the value of 'attachmentsVisible' to change.");
    }
    start();
  });
});
