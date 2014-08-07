var ENTITY_ID = 1;
var IRA_ID = 2;
var KSS_ACCOUNT_ID = 3;
var KSS_ID = 4;
var HOLDING_ID = 5;
var LOT_ID = 6;
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
      url: 'accounts/' + IRA_ID + '/holdings.json',
      responseText: [
        { id: HOLDING_ID, lots: { id: LOT_ID, account_id: KSS_ACCOUNT_ID, commodity_id: KSS_ID, purchase_date: '2014-01-01', shares_owned: 100, price: 10 } },
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '/commodities.json',
      responseText: [
        { id: KSS_ID, name: 'Knight Software Services', symbole: 'KSS'  }
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest("symbol", function() {
  expect(2);

  var keys = {entity_id: ENTITY_ID, account_id: IRA_ID, holding_id: HOLDING_ID};
  getHolding(new MoneyApp(), keys, function(holding) {
    ok(holding.symbol, 'should have a "symbol" property');
    if (holding.symbol) {
      equal(holding.symbol(), 'KSS', 'should have the correct value');
    }
    start();
  });
});
asyncTest("value", function() {
  ok(false, "Need to write the test");
  start();
});
asyncTest("shares", function() {
  ok(false, "Need to write the test");
  start();
});
asyncTest("cost", function() {
  ok(false, "Need to write the test");
  start();
});
asyncTest("gain_loss", function() {
  ok(false, "Need to write the test");
  start();
});
