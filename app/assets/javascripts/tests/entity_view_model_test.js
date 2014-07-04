module('EntityViewModel', {
  setup: function() {
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: 10, name: 'First Entity' }
      ]
    });
    $.mockjax({
      url: 'entities/10/accounts.json',
      responseText: [
        { id: 1, name: 'Checking', account_type: 'asset' },
        { id: 2, name: 'Salary', account_type: 'income' },
      ]
    });
    $.mockjax({
      url: 'entities/10.json',
      type: 'DELETE',
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
  getEntity(app, 10, function(entity) {
    ok(entity.edit, "should be a method on the object");
    entity.edit();
    ok(app.editEntity() && app.editEntity().id() == 10, "should set the 'editEntity' on the application object");

    start();
  });
});
asyncTest("remove", function() {
  expect(3);

  var app = new MoneyApp();
  getEntity(app, 10, function(entity) {
    ok(entity.remove, "should be a method on the object");
    var before = app.entities().length;
    app.entities.subscribe(function(entities) {
      var after = app.entities().length;
      equal(after - before, -1, "should reduce the number of entities by 1")
      var absent = _.every(app.entities(), function(e) { return e.id() != 10; });
      ok(absent, "should remove the entity from the entities collection");
      start();
    });
    entity.remove(true);
  });
});
