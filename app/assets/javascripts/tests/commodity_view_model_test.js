(function() {
  var ENTITY_ID = 1;
  var COMMODITY_ID = 2;
  module('CommodityViewModel', {
    setup: function() {
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
})()
