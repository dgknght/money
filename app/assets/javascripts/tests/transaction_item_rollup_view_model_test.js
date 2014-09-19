(function() {

var ENTITY_ID = 87678657;
var CHECKING_ID = 2439086;
var SALARY_ID = 23876;
var INCOME_TAX_ID = 78956;
var CREDIT_CARD_ID = 592375;
var DINING_ID = 2349876;
var MOOYAH_TRANSACTION_ID = 879567345;
var MOOYAH_ITEM_1_ID = 123987;
var MOOYAH_ITEM_2_ID = 89234768;
var PAYCHECK_TRANSACTION_ID = 9234;
var PAYCHECK_ITEM_1_ID = 23234342;
var PAYCHECK_ITEM_2_ID = 67459082567;

module('TransactionItemRollupViewModel', {
  setup: function() {
    $.mockjaxClear();
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: ENTITY_ID, name: 'First Entity' }
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/accounts.json',
      responseText: [
        { id: CHECKING_ID, name: 'Checking', account_type: 'asset' },
        { id: SALARY_ID, name: 'Salary', account_type: 'income' },
        { id: INCOME_TAX_ID, name: 'Income Tax', account_type: 'expense' },
        { id: CREDIT_CARD_ID, name: 'Credit Card', account_type: 'liability' },
        { id: DINING_ID, name: 'Dining', account_type: 'expense' }
      ]
    });
    $.mockjax({
      url: 'transactions/*.json',
      type: 'PUT',
      responseText: []
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + SALARY_ID,
      responseText: [
        {
          id: PAYCHECK_TRANSACTION_ID,
          transaction_date: '2014-01-13',
          description: 'Paycheck',
          items: [
            { id: PAYCHECK_ITEM_1_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000, reconciled: true },
            { id: PAYCHECK_ITEM_2_ID, account_id: SALARY_ID, action: 'credit', amount: 1000, reconciled: false }
          ]
        }
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + DINING_ID,
      responseText: [
        {
          id: MOOYAH_TRANSACTION_ID,
          transaction_date: '2014-01-14',
          description: 'Mooyah',
          items: [
            { id: MOOYAH_ITEM_1_ID, account_id: DINING_ID, action: 'debit', amount: 19, reconciled: true },
            { id: MOOYAH_ITEM_2_ID, account_id: CREDIT_CARD_ID, action: 'credit', amount: 19, reconciled: false }
          ]
        }
      ]
    });
    $.mockjax({
      url: 'transactions/' + PAYCHECK_TRANSACTION_ID + '/attachments.json',
      responseText: [
        { id: 1001, transaction_id: ENTITY_ID, name: 'Paystub', content_type: 'image/png' }
      ]
    });
    $.mockjax({
      url: 'transactions/' + MOOYAH_TRANSACTION_ID + '/attachments.json',
      responseText: []
    });
    $.mockjax({
      url: 'accounts/*/lots.json',
      responseText: []
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest('formattedTransactionDate', function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
      equal(item.description(), 'Paycheck', 'should have the correct value.');
      start();
    });
  });
});
asyncTest('otherAccountPath', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
      equal(item.otherAccountPath(), 'Checking', 'should have the correct value.');
      start();
    });
  });
});
asyncTest('reconciled', function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
      equal(item.reconciled(), false, 'should have the correct value.');
      equal(item.otherItem().reconciled(), true, 'should have the correct value.');
      start();
    });
  });
});
asyncTest('formattedPolarizedAmount', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
      equal(item.formattedPolarizedAmount(), '1,000.00', 'should have the correct value.');
      start();
    });
  });
});
asyncTest("polarizedAmount setter", function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', MOOYAH_ITEM_1_ID, function(item) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', MOOYAH_ITEM_1_ID, function(item) {
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
//  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(salary) {
//    var checking = app.entities().first().accounts().first(function(a) { return a.id() == 1; });
//    getFromLazyLoadedCollection(salary, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
      equal(item.formattedPolarizedAmount(), "1,000.00", "should have the correct value.");
      start();
    });
  });
});
asyncTest("formattedPolarizedAmount setter", function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
      item.formattedPolarizedAmount("123.45");
      equal(item.transaction_item.amount(), 123.45, "should update the underlying amount.");
      start();
    });
  });
});
asyncTest("toggleDetails", function() {
  expect(6);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: SALARY_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', PAYCHECK_ITEM_2_ID, function(item) {
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
    entity_id: ENTITY_ID,
    account_id: SALARY_ID,
    transaction_item_id: PAYCHECK_ITEM_2_ID
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
    entity_id: ENTITY_ID,
    account_id: SALARY_ID,
    transaction_item_id: PAYCHECK_ITEM_2_ID
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
    entity_id: ENTITY_ID,
    account_id: SALARY_ID,
    transaction_item_id: PAYCHECK_ITEM_2_ID
  };
  getTransactionItemRollup(app, ids, function(item) {
    ok(item.hasAttachment, "should be a property on the object");
    if (item.hasAttachment) {
      item.hasAttachment.subscribe(function(hasAttachment) {
        ok(hasAttachment, "should be true if the transaction has an attachment");
        start();
      });
      ok(item.hasAttachment() == false, "should be false until the attachments are loaded");
    } else {
      start();
    }
  });
});
asyncTest("toggleAttachmentsVisible", function() {
  expect(3);

  var app = new MoneyApp();
  var ids = {
    entity_id: ENTITY_ID,
    account_id: SALARY_ID,
    transaction_item_id: PAYCHECK_ITEM_2_ID
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

 })();
