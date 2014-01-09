//= require qunit-1.13.0
//= require single_page

module('MoneyApp');
test("should be creatable", function() {
  ok(new MoneyApp());
})
asyncTest("entities", 4, function() {
  /*
   * Currenty relying on data already in the database
   * Need to find a mocking framework so we can control 
   * what's in the database
   */
  var app = new MoneyApp();
  ok(app.entities, "It should have an entities property.");

  equal(app.entities(), 0, "The entities should not load until accessed.");

  app.entities.subscribe(function(entities) { 
    equal(app.entities().length, 1, "After loading, it should have one entity.");
    equal(app.entities()[0].name(), "Personal", "The entity should be called 'Personal'");
    start();
  });
})

module('EntityViewmodel');
test("should be creatable with valid data and a MoneyApp instance", function() {
  var app = new MoneyApp();
  var entity = {
    id: 1,
    name: "Personal"
  };
  ok(new EntityViewModel(entity, app));
})
