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
