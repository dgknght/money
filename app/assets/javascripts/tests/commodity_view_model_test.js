(function() {

  var ENTITY_ID = 2348;
  var COMMODITY_ID = 82946;
  var PRICE1_ID = 33476;
  var PRICE2_ID = 91824;
  module('CommodityViewModel', {
    setup: function() {
      $.mockjaxClear();
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'Personal' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/commodities.json',
        responseText: [
          { id: COMMODITY_ID, name: 'Knight Software Services', symbol: 'KSS', market: 'NYSE' }
        ]
      });
      $.mockjax({
        url: 'commodities/' + COMMODITY_ID + '/prices.json',
        responseText: [
          { id: PRICE2_ID, trade_date: '2014-02-01', price: 12 },
          { id: PRICE1_ID, trade_date: '2014-01-01', price: 10 }
        ]
      });
      $.mockjax({
        url: 'entities/*/accounts.json',
        responseText: []
      });
    },
    teardown: function() {
      $.mockjaxClear();
    }
  });

  asyncTest('symbol', function() {
    expect(2);

    getCommodity(new MoneyApp(), { entity_id: ENTITY_ID, commodity_id: COMMODITY_ID }, function(commodity) {
      ok(commodity.symbol, 'The commodity should have a property named "symbol"');
      if (commodity.symbol) {
        equal(commodity.symbol(), 'KSS', 'The symbol property should have the correct value');
      }
      start();
    });
  });

  asyncTest('name', function() {
    expect(2);

    getCommodity(new MoneyApp(), { entity_id: ENTITY_ID, commodity_id: COMMODITY_ID }, function(commodity) {
      ok(commodity.name, 'The commodity should have a property named "name"');
      if (commodity.name) {
        equal(commodity.name(), 'Knight Software Services', 'The name property should have the correct value');
      }
      start();
    });
  });

  asyncTest('market', function() {
    expect(2);

    getCommodity(new MoneyApp(), { entity_id: ENTITY_ID, commodity_id: COMMODITY_ID }, function(commodity) {
      ok(commodity.market, 'The commodity should have a property named "market"');
      if (commodity.market) {
        equal(commodity.market(), 'NYSE', 'The market property should have the correct value');
      }
      start();
    });
  });

  asyncTest('prices', function() {
    expect(2);

    getCommodity(new MoneyApp(), { entity_id: ENTITY_ID, commodity_id: COMMODITY_ID }, function(commodity) {
      ok(commodity.prices, 'The commodity should have a property named "prices"');
      if (commodity.prices) {
        var id = window.setTimeout(function() {
          start();
        }, 2000);
        commodity.prices.subscribe(function(prices) {
          if (prices.length == 2) {
            ok(true, 'Should contain the prices for the commodity');
            window.clearTimeout(id);
            start();
          }
        });
        commodity.prices();
      } else {
        start();
      }
    });
  });

  asyncTest('latestPrice', function() {
    expect(3);

    getCommodity(new MoneyApp(), { entity_id: ENTITY_ID, commodity_id: COMMODITY_ID }, function(commodity) {
      ok(commodity.latestPrice, 'The commodity should have a property named "latestPrice"');
      if (commodity.latestPrice) {
        var id = window.setTimeout(function() {
          start();
        }, 2000);
        var priceFound = false;
        commodity.latestPrice.subscribe(function(price) {
          if (priceFound) return;

          priceFound = true;
          equal(price.trade_date().toLocaleDateString(), '2/1/2014', 'The price should have the correct transaction date value');
          equal(price.price(), 12, 'The price should have the correct price value');
          window.clearTimeout(id);
          start();
        });
        commodity.latestPrice();
      } else {
        start();
      }
    });
  });
})();
