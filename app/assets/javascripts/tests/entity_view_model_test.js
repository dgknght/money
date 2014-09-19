(function() {

  var ENTITY_ID = 763548;
  var COMMODITY_ID = 23487;
  var CHECKING_ID = 9874365;
  var SALARY_ID = 97256;

  module('EntityViewModel', {
    setup: function() {
      $.mockjaxClear();
      $.mockjaxSettings.throwUnmocked = true;
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'First Entity' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: [
          { id: CHECKING_ID, name: 'Checking', account_type: 'asset' },
          { id: SALARY_ID, name: 'Salary', account_type: 'income' },
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '.json',
        responseText: []
      });
      $.mockjax({
        url: 'entities/1/accounts.json',
        responseText: []
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/.json',
        type: 'DELETE',
        responseText: []
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/commodities.json',
        responseText: [
          { id: 99, name: 'other', symbol: 'O', market: 'NYSE' },
          { id: COMMODITY_ID, name: 'Knight Software Services', symbol: 'KSS', market: 'NYSE' }
        ]
      });
      $.mockjax({
        url: 'accounts/*/lots.json',
        responseText: []
      });
      $.mockjax({
        url: 'commodities/*/prices.json',
        responseText: []
      });
    },
    teardown: function() {
      $.mockjaxClear();
    }
  });
  test("should be creatable with valid data and a MoneyApp instance", function() {
    var app = new MoneyApp();
    var entity = {
      id: 1,
      name: "Personal"
    };
    ok(new EntityViewModel(entity, app));
  })
  test("name should be required", function() {
    var entity = new EntityViewModel({}, new MoneyApp());
    equal(entity.validate(), false, "The model should not be valid if the name is missing.");
    entity.name("test");
    equal(entity.validate(), true, "The model should be valid if the name is supplied.");
  })
  asyncTest("should have a list of accounts", function() {
    var app = new MoneyApp();
    app.entities.subscribe(function(entities) {
      if (entities.length == 0) return;
      if (entities.length > 1)
        throw 'too many entities'

      var entity = app.entities().first();
      ok(entity.accounts, "It should have an accounts property.");

      entity.accounts.subscribe(function(accounts) {
        if (accounts.length < 2) return;
        if (accounts.length > 2)
          throw 'too many accounts'

        equal(entity.accounts()[0].name(), 'Checking');
        equal(entity.accounts()[1].name(), 'Salary');

        start();
      });

      equal(entity.accounts(), 0, "The property should not load until accessed.");
    });
    app.entities();
  })
  asyncTest("edit", function() {
    var app = new MoneyApp();
    getEntity(app, ENTITY_ID, function(entity) {
      ok(entity.edit, "should be a method on the object");
      entity.edit();
      ok(app.editEntity() && app.editEntity().id() == ENTITY_ID, "should set the 'editEntity' on the application object");

      start();
    });
  });
  asyncTest("remove", function() {
    expect(3);

    var app = new MoneyApp();
    getEntity(app, ENTITY_ID, function(entity) {
      ok(entity.remove, "should be a method on the object");
      var before = app.entities().length;
      app.entities.subscribe(function(entities) {
        var after = app.entities().length;
        equal(after - before, -1, "should reduce the number of entities by 1")
        var absent = _.every(app.entities(), function(e) { return e.id() != ENTITY_ID; });
        ok(absent, "should remove the entity from the entities collection");
        start();
      });
      entity.remove(true);
    });
  });

  asyncTest("getCommodity", function() {
    expect(3);

    getEntity(new MoneyApp(), ENTITY_ID, function(entity) {
      ok(entity.getCommodity, 'entity should have a method called "getCommodity"');
      if (entity.getCommodity) {
        entity.getCommodity(COMMODITY_ID, function(commodity) {
          ok(commodity, 'it should not produce a null value for a valid id');
          var returnedId = commodity ? commodity.id() : null;
          equal(returnedId, COMMODITY_ID, 'it should return the correct commodity');
          start();
        });
      } else {
        start();
      }
    });
  });
})();
