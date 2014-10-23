(function() {
  var ENTITY_ID = 295836;
  var CHECKING_ID = 943725;
  var IRA_ID = 83746;
  var KSS_ACCOUNT_ID = 84726;
  var NEW_TRANSACTION_ID = 38756;
  var NEW_TRANSACTION_ITEM_1_ID = 195836;
  var NEW_TRANSACTION_ITEM_2_ID = 94816;
  module('NewCommodityTransactionViewModel', {
    setup: function() {
      $.mockjaxClear();
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'Personal' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: [
          { id: CHECKING_ID, name: 'Checking', account_type: 'asset', content_type: 'currency' },
          { id: IRA_ID, name: 'IRA', account_type: 'asset', content_type: 'commodities' },
          { id: KSS_ACCOUNT_ID, name: 'KSS', account_type: 'asset', content_type: 'commodity', parent_id: IRA_ID }
        ]
      });
      $.mockjax({
        url: 'accounts/*/lots.json',
        responseText: []
      });
      $.mockjax({
        url: 'accounts/' + IRA_ID + '/create_commodity_transaction.json',
        type: 'POST',
        responseText: {
          id: NEW_TRANSACTION_ID,
          transaction_date: new Date().toISOString(),
          description: 'Purchased 100 shares of KSS at 12.00',
          items: [
            { id: NEW_TRANSACTION_ITEM_1_ID, account_id: IRA_ID, action: 'credit', amount: 1200 },
            { id: NEW_TRANSACTION_ITEM_2_ID, account_id: KSS_ACCOUNT_ID, action: 'debit', amount: 1200 }
          ]
        }
      });
    }
  });
  asyncTest('transaction_date', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.transaction_date, 'The new holding instance should have a "transaction_date" method');
      if (account.newCommodityTransaction.transaction_date) {
        equal(account.newCommodityTransaction.transaction_date().toLocaleDateString(), new Date().toLocaleDateString(), 'The "transaction_date" method should default to today');
      }
      start();
    });
  });
  asyncTest('action', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.action, 'The new holding instance should have a "action" method');
      if (account.newCommodityTransaction.action) {
        equal(account.newCommodityTransaction.action(), 'buy', 'The "action" method should default to "buy"');
      }
      start();
    });
  });
  asyncTest('symbol', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.symbol, 'The new holding instance should have a "symbol" method');
      if (account.newCommodityTransaction.symbol) {
        equal(account.newCommodityTransaction.symbol(), null, 'The "symbol" method should default to null');
      }
      start();
    });
  });
  asyncTest('shares', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.shares, 'The new holding instance should have a "shares" method');
      if (account.newCommodityTransaction.shares) {
        equal(account.newCommodityTransaction.shares(), null, 'The "shares" method should default to null');
      }
      start();
    });
  });
  asyncTest('value', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.value, 'The new holding instance should have a "value" method');
      if (account.newCommodityTransaction.value) {
        equal(account.newCommodityTransaction.value(), null, 'The "value" method should default to null');
      }
      start();
    });
  });
  asyncTest('price', function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.price, 'The instance should have a "price" method');
      if (account.newCommodityTransaction.price) {
        account.newCommodityTransaction.shares(100);
        account.newCommodityTransaction.value(1200);
        equal(account.newCommodityTransaction.price(), 12, 'The "price" method should return the correct value');
      }
      start();
    });
  });
  asyncTest('validate', function() {
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.newCommodityTransaction.validate, 'The instance should have a "validate" method');
      if (account.newCommodityTransaction.validate) {
        var viewModel = account.newCommodityTransaction;

        viewModel.transaction_date(new Date(2014, 1, 27));
        viewModel.symbol('KSS');
        viewModel.shares(100);
        viewModel.value(1200);
        ok(viewModel.validate(), 'The view model should be valid with a transaction_date, symbol, shares, and value');

        // action
        viewModel.action(null);
        equal(viewModel.validate(), false, '"action" should be required');

        viewModel.action('not_a_valid_action');
        equal(viewModel.validate(), false, '"action" must be "buy" or "sell"');
        equal(viewModel.action.errorMessage(), 'The value must be one of these values: buy, sell.', "The property should have the correct error message");

        viewModel.action('buy');

        // symbol
        viewModel.symbol(null);
        equal(viewModel.validate(), false, '"symbol" should be required');

        viewModel.symbol('KSS');


        // shares
        viewModel.shares(null);
        equal(viewModel.validate(), false, '"shares" should be required');
        viewModel.shares('not_a_number');
        equal(viewModel.validate(), false, '"shares" should be a number');

        viewModel.shares(100);

        // value
        viewModel.value(null);
        equal(viewModel.validate(), false, '"value" should be required');
        viewModel.value('not_a_number');
        equal(viewModel.validate(), false, '"value" should be a number');

        viewModel.value(1200);

        // transaction_date
//        viewModel.formattedTransactionDate(null);
//        equal(viewModel.validate(), false, '"transaction_date" should be required');
//        viewModel.formattedTransactionDate('not_a_date');
//        equal(viewModel.validate(), false, '"transaction_date" should be a date');
      }

      start();
    });
  });
  //  Couldn't get this working because of a false AJAX not mocked error
//  asyncTest('save - when purchasing', function() {
//    expect(1);
//
//    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(account) {
//      var viewModel = account.newCommodityTransaction;
//      viewModel.symbol('KSS');
//      viewModel.shares(100);
//      viewModel.value(1200);
//
//      ok(viewModel.save, 'The instance should have a "save" method');
//      if (viewModel.save) {
//        var timeout = window.setTimeout(function() {
//          ok(false, 'The save operation never completed');
//          start();
//        }, 5000);
//
//        viewModel.save(
//          function() {
//            window.clearTimeout(timeout);
//            equal(account.lots().length, 1, 'should create a new lot');
//            start();
//          },
//          function(error) {
//            window.clearTimeout(timeout);
//            ok(false, error);
//            start();
//          }
//        );
//      } else {
//        start();
//      }
//    });
//  });
})();
