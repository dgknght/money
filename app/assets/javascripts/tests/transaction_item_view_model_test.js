(function() {

var ENTITY_ID = 10;
var CHECKING_ID = 101;
var SALARY_ID = 102;
var TRANSACTION_ID = 1001;
var TRANSACTION_ITEM_1_ID = 10001;
var TRANSACTION_ITEM_2_ID = 10002;

module('TransactionItemViewModel', {
  setup: function() {
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
        { id: SALARY_ID, name: 'Salary', account_type: 'income' }
      ]
    });
    $.mockjax({
      url: 'transactions/*/attachments.json',
      responseText: [
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + CHECKING_ID,
      responseText: [
        {
          id: TRANSACTION_ID,
          transaction_date: '2014-01-01',
          description: 'Salary',
          items: [
            { id: TRANSACTION_ITEM_1_ID, account_id: CHECKING_ID, action: 'debit', amount: "1000" },
            { id: TRANSACTION_ITEM_2_ID, account_id: SALARY_ID, action: 'credit', amount: "1000" }
          ]
        },
      ]
    });
    $.mockjax({
      url: 'accounts/*/lots.json',
      responseText: []
    });
    $.mockjaxSettings.throwUnmocked = true;
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest("amount", function() {
  expect(1);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', TRANSACTION_ITEM_1_ID, function(item) {
      ok(_.isNumber(item.transaction_item.amount() + 1), "The amount should be a number");
      start();
    });
  });
});
asyncTest("accountPath", function() {
  expect(2);

  var app = new MoneyApp();
  getAccount(app, { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', TRANSACTION_ITEM_1_ID, function(item) {
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
  getAccount(app, { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', TRANSACTION_ITEM_1_ID, function(item) {
      var transaction = item.transaction_item.transaction;
      item.transaction_item.remove();
      equal(1, transaction.items().length, "The number of items in the transaction should decrease by one after remove.");

      var isAbsent = _.every(transaction.items(), function(i) { return i.id() != item.id()});
      ok(isAbsent, "The item should not longer be in the transaction after remove.");

      equal(transaction.debitAmount(), 0, "The debit amount on the transaction should reflect the removed item.");

      var expected = {
        id: TRANSACTION_ID,
        transaction_date: '2014-01-01',
        description: 'Salary',
        items_attributes: [
          { id: TRANSACTION_ITEM_1_ID, account_id: CHECKING_ID, action: 'debit', amount: 0, _destroy: 1 },
          { id: TRANSACTION_ITEM_2_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 }
        ]
      };
      deepEqual(transaction.toJson(), expected, "The serialized transaction should reflect the removed item.");

      start();
    });
  });
});

})();
