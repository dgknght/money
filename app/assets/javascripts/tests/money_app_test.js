(function() {

var ENTITY_ID = 287634;

module('MoneyApp', {
  setup: function() {
    $.mockjaxClear();
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: ENTITY_ID, name: 'First Entity' }
      ]
    });
    $.mockjax({
      url: 'entities/' + ENTITY_ID + '.json',
      type: 'DELETE',
      responseText: []
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
test("should be creatable", function() {
  ok(new MoneyApp());
})
test("editEntity", function() {
  var app = new MoneyApp();
  ok(app.editEntity, "should be a property on the object.");
});
test("newEntity", function() {
  var app = new MoneyApp();
  var before = app.entities().length;
  ok(app.newEntity, "should be a method on the object");
  var entity = app.newEntity();
  ok(entity, "should not return null");
  var after = app.entities().length;
  equal(after - before, 1, "should increase the number of entities");
  ok(app.editEntity(), "should set the 'editEntity' property to the new entity");
});
asyncTest("editSelectedEntity", function() {
  expect(3);

  var app = new MoneyApp();
  ok(app.editSelectedEntity, "should be a method on the object");

  getEntity(app, ENTITY_ID, function(entity) {
    app.selectedEntity(entity);
    app.editSelectedEntity();
    ok(app.editEntity(), "should set the value of editEntity");
    equal(app.editEntity().id(), ENTITY_ID, "should set the value of editEntity to the same entity as selectedEntity");

    start();
  });
});
asyncTest("removeSelectedEntity", function() {
  expect(3);

  var app = new MoneyApp();
  ok(app.removeSelectedEntity, "should be a method on the object");

  getEntity(app, ENTITY_ID, function(entity) {
    app.selectedEntity(entity);

    var before = app.entities().length;
    app.entities.subscribe(function(entities) {
      var after = app.entities().length;
      equal(after - before, -1, "should reduce the number of entities by 1");
      var absent = _.every(app.entities(), function(e) { return e.id() != ENTITY_ID; });
      ok(absent, "should remove the entity from the entities collection");
      start();
    });

    app.removeSelectedEntity(true);
  });
});
asyncTest("entities", 4, function() {
  var app = new MoneyApp();
  ok(app.entities, "It should have an entities property.");

  app.entities.subscribe(function(entities) { 
    if (entities.length == 0) return;
    if (entities.length > 1 )
      throw 'Too many entities returned';

    equal(app.entities().length, 1, "After loading, it should have one entity.");
    equal(app.entities()[0].name(), "First Entity", "The entity should be called 'Personal'");
    start();
  });

  equal(app.entities(), 0, "The entities should not load until accessed.");
})

})();
