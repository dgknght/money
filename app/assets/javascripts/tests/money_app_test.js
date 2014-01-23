module('MoneyApp', {
  setup: function() {
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: 1, name: 'First Entity' }
      ]
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
