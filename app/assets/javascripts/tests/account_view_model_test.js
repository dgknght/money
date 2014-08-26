(function() {
  var ENTITY_ID = 10;
  var CHECKING_ID = 1;
  var SALARY_ID = 2;
  var FOUR_OH_ONE_K_ID = 3;
  var KSS_ACCOUNT_ID = 4
  var PRICE_ID = 5;
  var KSS_ID = 6;
  var ACCOUNTS = [
    { id: CHECKING_ID, name: 'Checking', account_type: 'asset', content_type: 'currency' },
    { id: SALARY_ID, name: 'Salary', account_type: 'income', content_type: 'currency' },
    { id: FOUR_OH_ONE_K_ID, name: '401k', account_type: 'asset', content_type: 'commodities' },
    { id: KSS_ACCOUNT_ID, name: 'KSS', account_type: 'asset', content_type: 'commodity' }
  ];
  module('AccountViewModel', {
    setup: function() {
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'First Entity' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: ACCOUNTS
      });
      $.mockjax({
        url: 'accounts/' + KSS_ACCOUNT_ID + '/lots.json',
        responseText: [
          {
            id:1,
            account_id: KSS_ACCOUNT_ID,
            commodity_id: KSS_ID,
            price:10.0,
            shares_owned:100.0,
            purchase_date:"2014-07-15"
          }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/commodities.json',
        responseText: [
          { id: KSS_ID, name: 'Knight Software Services', symbol: 'KSS', market: 'NYSE' }
        ]
      });
      $.mockjax({
        url: 'commodities/' + KSS_ID + '/prices.json',
        responseText: [ ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + CHECKING_ID,
        responseText: [
          { 
            id: 2,
            transaction_date: '2014-01-15',
            description: 'Paycheck',
            items: [
              { id: 1, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: 2, account_id: SALARY_ID, action: 'credit', amount: 1000 }
            ]
          },
          { 
            id: 1,
            transaction_date: '2014-01-01',
            description: 'Paycheck',
            items: [
              { id: 1, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: 2, account_id: SALARY_ID, action: 'credit', amount: 1000 }
            ]
          }
        ]
      });
    },
    teardown: function() {
      $.mockjaxClear();
    }
  });
  asyncTest("validation", function() {
    expect(4);

    var app = new MoneyApp();
    getEntity(app, 10, function(entity) {
      var account = new AccountViewModel({}, entity);
      account.name('Test');
      account.account_type('asset');
      ok(account.validate(), 'The account should be valid with a name and an account type');

      account.name(null);
      equal(account.validate(), false, 'The account should not be valid without a name');

      account.name('test');
      account.account_type(null);
      equal(account.validate(), false, 'The account should not be valid without an account type');

      account.account_type('not a valid type');
      equal(account.validate(), false, 'The account should not be valid without a valid account type');

      start();
    });
  })
  asyncTest("transaction_items", function() {
    expect(7);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: 1}, function(account) {
      ok(account.transaction_items, "The account should have a transaction_items property.");
      account.transaction_items.subscribe(function(items) {
        if (items.length != 2) return;

        equal(account.transaction_items().length, 2, "The account should have 2 transaction item.");
        var item = account.transaction_items().first();
        equal(item.id(), 1, "The first transaction item should have the right account_id value.");
        equal(item.action(), 'debit', "The first transaction item should have the right action value.");
        equal(item.polarizedAmount(), 1000, "The first transaction item should have the right amount value.");
        equal(item.transaction_item.transaction.transaction_date().toLocaleDateString(), '1/15/2014', "The transaction items should be in reverse chronological order.");
        start();
      });
      equal(account.transaction_items().length, 0, "The transaction_items property should not load until accessed.");
    });
  });
  asyncTest("commoditiesMenuVisible", function() {
    expect(2);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: FOUR_OH_ONE_K_ID }, function(commoditiesAccount) {
      equal(commoditiesAccount.commoditiesMenuVisible(), true, 'Commodities accounts should show the commodities menu');

      otherAccount = commoditiesAccount.entity.getAccount(1);
      equal(otherAccount.commoditiesMenuVisible(), false, 'Non-commodities accounts should not show the commodities menu');
      start();
    });
  });
  asyncTest("holdingsVisible", function() {
    expect(6);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: FOUR_OH_ONE_K_ID }, function(commoditiesAccount) {
      equal(commoditiesAccount.holdingsVisible(), true, 'Commodities accounts should show the holdings by default');
      commoditiesAccount.transactionItemsVisible(true);
      equal(commoditiesAccount.holdingsVisible(), false, 'holdingsVisible should be false if transactionItemsVisible is true');

      otherAccount = commoditiesAccount.entity.getAccount(1);
      equal(otherAccount.holdingsVisible(), false, 'Non-commodities accounts should not show holdings');
      equal(otherAccount.transactionItemsVisible(), true, 'Non-commodities accounts should only show transaction items');
      otherAccount.holdingsVisible(true);
      equal(otherAccount.holdingsVisible(), false, 'Non-commodities accounts should not show holdings');
      equal(otherAccount.transactionItemsVisible(), true, 'Non-commodities accounts should only show transaction items');
      start();
    });
  });
  asyncTest("showTransactionItems", function() {
    expect(2);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: FOUR_OH_ONE_K_ID }, function(commoditiesAccount) {
      equal(commoditiesAccount.transactionItemsVisible(), false, 'Commodities accounts should not show the transactions items by default');
      commoditiesAccount.showTransactionItems();
      equal(commoditiesAccount.transactionItemsVisible(), true, 'transactionItemsVisible should be true after calling showTransactionItems');
      start();
    });
  });
  asyncTest("showHoldings", function() {
    expect(1);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: FOUR_OH_ONE_K_ID }, function(commoditiesAccount) {
      commoditiesAccount.holdingsVisible(false);
      commoditiesAccount.showHoldings();
      equal(commoditiesAccount.holdingsVisible(), true, 'holdingsVisible should be true after calling showHoldings');
      start();
    });
  });
  asyncTest("value for a COMMODITY account", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID }, function(account) {
      ok(account.value, 'The object should have a "value" method');
      if (account.value) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the "value"');
          start();
        }, 2000);
        account.value.subscribe(function(value) {
          window.clearTimeout(timeoutId);
          equal(value, 1200, 'The value method should return the correct value');
          start();
        });
        account.value();
      } else {
        start();
      }
    });
  });
  asyncTest("formattedValue", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
  asyncTest("cost", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
  asyncTest("formattedCost", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
  asyncTest("shares", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
  asyncTest("formattedShares", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
  asyncTest("gainLoss", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
  asyncTest("formattedGainLoss", function() {
    expect(1);
    ok(false, 'need to write the test');
    start();
  });
})();
