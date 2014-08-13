(function() {
  var ENTITY_ID = 1;
  var IRA_ID = 2;
  var KSS_ACCOUNT_ID = 3;
  var KSS_ID = 4;
  var HOLDING_ID = 5;
  var LOT_ID = 6;

  module('LotViewModel', {
    setup: function() {
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'Personal' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: [
          { id: IRA_ID, name: 'IRA', account_type: 'asset', content_type: 'commodities' },
          { id: KSS_ACCOUNT_ID, name: 'KSS', account_type: 'asset', content_type: 'commodity', parent_id: IRA_ID }
        ]
      });
      $.mockjax({
        url: 'accounts/' + KSS_ACCOUNT_ID + '/holdings.json',
        responseText: [
          { id: HOLDING_ID, lots: [ { id: LOT_ID, account_id: KSS_ACCOUNT_ID, commodity_ID: KSS_ID, price: 10, shares_owned: 100, purchase_date: '2014-02-01' } ] }
        ]
      });
    },
    teardown: function() {
      $.mockjaxClear();
    }
  });
  asyncTest('account_id', function() {
    expect(3);

    getHolding(new MoneyApp(), {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID}, function(holding) {
      var lot = _.first(holding.lots());
      ok(lot, 'The lot should be available in the list of lots for the holding');
      ok(lot.account_id, 'The lot should have an account_id property');
      if (lot.account_id) {
        equal(lot.account_id(), KSS_ACCOUNT_ID, 'The account_id property should have the correct value');
      }
      start();
    });
  });
  asyncTest('commodity_id', function() {
    ok(false, 'Need to write the test.');
    start();
  });
  asyncTest('price', function() {
    ok(false, 'Need to write the test.');
    start();
  });
  asyncTest('shares_owned', function() {
    ok(false, 'Need to write the test.');
    start();
  });
})()
