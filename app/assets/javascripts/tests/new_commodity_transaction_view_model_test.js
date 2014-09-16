(function() {
  var ENTITY_ID = 1;
  var ACCOUNT_ID = 2;
  module('NewCommodityTransactionViewModel', {
    setup: function() {},
    teardown: function() {}
  });
  asyncTest('transaction_date', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: ACCOUNT_ID }, function(account) {
      ok(account.newCommodityTransaction.transaction_date, 'The new holding instance should have a "transaction_date" method');
      if (account.newCommodityTransaction.transaction_date) {
        equal(account.newCommodityTransaction.transaction_date().toLocaleDateString(), new Date().toLocaleDateString(), 'The "action" method should default to today');
      }
      start();
    });
  });
  asyncTest('action', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: ACCOUNT_ID }, function(account) {
      ok(account.newCommodityTransaction.action, 'The new holding instance should have a "action" method');
      if (account.newCommodityTransaction.action) {
        equal(account.newCommodityTransaction.action(), 'buy', 'The "action" method should default to "buy"');
      }
      start();
    });
  });
  asyncTest('symbol', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: ACCOUNT_ID }, function(account) {
      ok(account.newCommodityTransaction.symbol, 'The new holding instance should have a "symbol" method');
      if (account.newCommodityTransaction.symbol) {
        equal(account.newCommodityTransaction.symbol(), null, 'The "symbol" method should default to null');
      }
      start();
    });
  });
  asyncTest('shares', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: ACCOUNT_ID }, function(account) {
      ok(account.newCommodityTransaction.shares, 'The new holding instance should have a "shares" method');
      if (account.newCommodityTransaction.shares) {
        equal(account.newCommodityTransaction.shares(), null, 'The "shares" method should default to null');
      }
      start();
    });
  });
  asyncTest('value', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: ACCOUNT_ID }, function(account) {
      ok(account.newCommodityTransaction.value, 'The new holding instance should have a "value" method');
      if (account.newCommodityTransaction.value) {
        equal(account.newCommodityTransaction.value(), null, 'The "value" method should default to null');
      }
      start();
    });
  });
})();
