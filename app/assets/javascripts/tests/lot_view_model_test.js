(function() {
  var ENTITY_ID = 1;
  var IRA_ID = 2;
  var KSS_ACCOUNT_ID = 3;
  var KSS_ID = 4;
  var HOLDING_ID = 5;
  var LOT_ID = 6;
  var PRICE_ID = 7;

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
        url: 'accounts/' + IRA_ID + '/lots.json',
        responseText: []
      });
      $.mockjax({
        url: 'accounts/' + KSS_ACCOUNT_ID + '/lots.json',
        responseText: [
          {
            id: LOT_ID,
            account_id: KSS_ACCOUNT_ID,
            commodity_id: KSS_ID,
            price: 10,
            shares_owned: 100,
            purchase_date: '2014-02-01'
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
        responseText: [
          { id: PRICE_ID, trade_date: '2014-08-01', price: 12 }
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
    expect(3);

    getHolding(new MoneyApp(), {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID}, function(holding) {
      var lot = _.first(holding.lots());
      ok(lot, 'The lot should be available in the list of lots for the holding');
      ok(lot.commodity_id, 'The lot should have an commodity_id property');
      if (lot.commodity_id) {
        equal(lot.commodity_id(), KSS_ID, 'The commodity_id property should have the correct value');
      }
      start();
    });
  });
  asyncTest('price', function() {
    expect(3);

    getHolding(new MoneyApp(), {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID}, function(holding) {
      var lot = _.first(holding.lots());
      ok(lot, 'The lot should be available in the list of lots for the holding');
      ok(lot.price, 'The lot should have an price property');
      if (lot.price) {
        equal(lot.price(), 10, 'The price property should have the correct value');
      }
      start();
    });
  });
  asyncTest('shares_owned', function() {
    expect(3);

    getHolding(new MoneyApp(), {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID}, function(holding) {
      var lot = _.first(holding.lots());
      ok(lot, 'The lot should be available in the list of lots for the holding');
      ok(lot.shares_owned, 'The lot should have an shares_owned property');
      if (lot.shares_owned) {
        equal(lot.shares_owned(), 100, 'The shares_owned property should have the correct value');
      }
      start();
    });
  });
  asyncTest('currentValue', function() {
    expect(2);

    getLot(new MoneyApp(), {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, lot_id: LOT_ID}, function(lot) {
      ok(lot.currentValue, 'The object should have a "currentValue" method');
      if (lot.currentValue) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'never received the event');
          start();
        }, 2000);
        lot.currentValue.subscribe(function(currentValue) {
          window.clearTimeout(timeoutId);
          equal(currentValue, 1200, 'The method should return the correct value');
          start();
        });
      } else {
        start();
      }
    });
  });
})()
