(function() {
  var ENTITY_ID = 76512456;
  var KSS_ID = 123453;
  var PRICE_ID = 987;

  module('PriceViewModel', {
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
          { id: KSS_ID, name: 'Knight Software Services', symbol: 'KSS', market: 'NYSE' }
        ]
      });
      $.mockjax({
        url: 'commodities/' + KSS_ID + '/prices.json',
        responseText: [
          { id: PRICE_ID, trade_date: '2014-02-01', price: 12 }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: []
      });
    },
    teardown: function() {
      $.mockjaxClear();
    }
  });
  asyncTest('trade_date', function() {
    expect(2);

    var ids = { entity_id: ENTITY_ID, commodity_id: KSS_ID, price_id: PRICE_ID };
    getPrice(new MoneyApp(), ids, function(price) {
      ok(price.trade_date, 'it should have a property called "price"');
      if (price.trade_date) {
        equal(price.trade_date().toLocaleDateString(), '2/1/2014', 'The trade_date property should have the correct value');
      }
      start();
    });
  });
  asyncTest('price', function() {
    expect(3);

    var ids = { entity_id: ENTITY_ID, commodity_id: KSS_ID, price_id: PRICE_ID };
    getPrice(new MoneyApp(), ids, function(price) {
      ok(price.price, 'it should have a property called "price"');
      if (price.price) {
        ok(!isNaN(price.price()), 'The value should be a number');
        equal(price.price(), 12, 'The price property should have the correct value');
      }
      start();
    });
  });
  asyncTest('commodity', function() {
    expect(2);

    var ids = { entity_id: ENTITY_ID, commodity_id: KSS_ID, price_id: PRICE_ID };
    getPrice(new MoneyApp(), ids, function(price) {
      ok(price.commodity, 'it should have a field "commodity"');
      if (price.commodity) {
        equal(price.commodity.id(), KSS_ID);
      }
      start();
    });
  });
})();
