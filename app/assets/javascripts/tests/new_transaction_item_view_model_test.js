(function() {

var ENTITY_ID = 10;
var CHECKING_ID = 101;
var DINING_ID = 102;
var TRANSACTION_ID = 1000;
var TRANSACTION_ITEM_1_ID = 10000;
var TRANSACTION_ITEM_2_ID = 10001;

module('NewTransactionItemViewModel', {
  setup: function() {
    $.mockjaxSettings.throwUnmocked = true;
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: ENTITY_ID, name: 'First Entity' }
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/accounts.json',
      responseText: [
        { id: CHECKING_ID, name: 'Checking', account_type: 'asset', balance: 0 },
        { id: DINING_ID, name: 'Dining', account_type: 'expense', balance: 0 }
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + DINING_ID,
      responseText: []
    });
    $.mockjax({
      url: 'transactions/*/attachments.json',
      responseText: []
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/transactions.json',
      type: 'POST',
      responseText: {
        id: TRANSACTION_ID,
        transaction_date: '2014-01-01',
        description: 'Mooyah',
        items: [
          { id: TRANSACTION_ITEM_1_ID, account_id: DINING_ID, action: 'debit', amount: 5 },
          { id: TRANSACTION_ITEM_2_ID, account_id: CHECKING_ID, action: 'credit', amount: 5 }
        ]
      }
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
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    equal(account.newTransactionItem.formattedTransactionDate(), new Date().toLocaleDateString(), "It should default to today's date.");
    start();
  });
});
asyncTest('description', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    ok(account.newTransactionItem.description);
    start();
  });
});
asyncTest('otherAccountPath', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    ok(account.newTransactionItem.otherAccountPath);
    start();
  });
});
asyncTest('amount', function() {
  expect(1);
  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    ok(account.newTransactionItem.amount);
    start();
  });
});
asyncTest('save balance', function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: DINING_ID }, function(account) {
    account.newTransactionItem.formattedTransactionDate('1/1/2014');
    account.newTransactionItem.description('Mooyah');
    account.newTransactionItem.otherAccountPath('Checking');
    account.newTransactionItem.amount(5);

    account.transaction_items();

    account.transaction_items.subscribe(function(items) {
      var item = _.last(items);
      equal(item.polarizedAmount(), 5, "The amount property should have the correct value.");
      equal(item.action(), 'debit', "The action property should have the correct value.");
      equal(item.balance(), 5, "The balance property should have the correct value.");

      start();
    });

    account.newTransactionItem.save();
  });
});

})();
