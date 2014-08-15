(function() {
  var ENTITY_ID = 1;
  var IRA_ID = 2;
  var KSS_ACCOUNT_ID = 3;
  var KSS_ID = 4;
  var HOLDING_ID = 5;
  var LOT1_ID = 6;
  var LOT2_ID = 7;
  var PRICE_ID = 8;
  module('HoldingViewModel', {
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
          { id: IRA_ID, name: 'IRA' },
          { id: KSS_ACCOUNT_ID, name: 'KSS' }
        ]
      });
      $.mockjax({
        url: 'accounts/' + KSS_ACCOUNT_ID + '/holdings.json',
        responseText: [
          {
            id: HOLDING_ID,
            lots: [
              {
                id: LOT1_ID,
                account_id: KSS_ACCOUNT_ID,
                commodity_id: KSS_ID,
                purchase_date: '2014-01-01',
                shares_owned: 100,
                price: 10
              },
              {
                id: LOT2_ID,
                account_id: KSS_ACCOUNT_ID,
                commodity_id: KSS_ID,
                purchase_date: '2014-02-01',
                shares_owned: 100,
                price: 12
              }
            ]
          },
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/commodities.json',
        responseText: [
          { id: KSS_ID, name: 'Knight Software Services', symbol: 'KSS', market: 'NYSE'  }
        ]
      });
      $.mockjax({
        url: 'commodities/' + KSS_ID + '/prices.json',
        responseText: [
          { id: PRICE_ID, trade_date: '2014-08-14', price: 14 }
        ]
      });
    },
    teardown: function() {
      $.mockjaxClear();
    }
  });
  asyncTest("symbol", function() {
    expect(2);

    var keys = {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID};
    getHolding(new MoneyApp(), keys, function(holding) {
      ok(holding.symbol, 'should have a "symbol" property');
      if (holding.symbol) {
        // assume the commodity property has not been loaded yet
        holding.symbol.subscribe(function(symbol) {
          equal(symbol, 'KSS', 'should have the correct value');
          start();
        });
      }
    });
  });
  asyncTest("value", function() {
    expect(2);

    var keys = {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID};
    getHolding(new MoneyApp(), keys, function(holding) {
      ok(holding.value, 'should have a "value" property');
      if (holding.value) {
        var id = window.setTimeout(start, 5000);
        holding.value.subscribe(function(value) {
          equal(value, 2800, 'The "value" property should have the correct value');
          window.clearTimeout(id);
          start();
        });
      }
    });
  });
  asyncTest("shares", function() {
    expect(2);

    var keys = {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID};
    getHolding(new MoneyApp(), keys, function(holding) {
      ok(holding.shares, 'should have a "shares" property');
      if (holding.shares) {
        equal(holding.shares(), 200, 'should have the correct shares');
      }
      start();
    });
  });
  asyncTest("cost", function() {
    expect(2);

    var keys = {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID};
    getHolding(new MoneyApp(), keys, function(holding) {
      ok(holding.cost, 'should have a "cost" property');
      if (holding.cost) {
        equal(holding.cost(), 2200, 'should have the correct cost');
      }
      start();
    });
  });
  asyncTest("gain_loss", function() {
    expect(2);

    var keys = {entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID, holding_id: HOLDING_ID};
    getHolding(new MoneyApp(), keys, function(holding) {
      ok(holding.gain_loss, 'should have a "gain_loss" property');
      if (holding.gain_loss) {
        var id = window.setTimeout(start, 5000);
        holding.gain_loss.subscribe(function(gain_loss) {
          equal(gain_loss, 600, 'The "gain_loss" property should have the correct value');
          window.clearTimeout(id);
          start();
        });
        holding.gain_loss();
      }
    });
  });
})();
