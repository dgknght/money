//= require qunit-1.13.0
//= require single_page
//= require jquery.mockjax

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

module('EntityViewmodel', {
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
asyncTest("should have a list of accounts", 4, function() {
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

module('AccountViewModel', {
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
      url: 'entities/10/transactions.json?account_id=1',
      responseText: [
        { 
          id: 1, 
          transaction_date: '2014-01-01',
          description: 'Salary',
          items: [
            { id: 1, account_id: 1, action: 'debit', amount: 1000 },
            { id: 2, account_id: 2, action: 'credit', amount: 1000 }
          ]
        },
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest("should have a transaction_items property", function() {
  expect(6);

  var app = new MoneyApp();
  app.entities.subscribe(function(entities) {
    if (entities.length == 0) return;
    if (entities.length > 1) throw 'too many entities'

    var entity = app.entities().first();
    entity.accounts.subscribe(function(accounts) {
      if (accounts.length < 2) return;
      if (accounts.length > 2) throw 'too many accounts';

      var account = app.entities().first().accounts().first();

      ok(account.transaction_items, "The account should have a transaction_items property.");
      account.transaction_items.subscribe(function(items) {
        if (items.length == 0) return;

        equal(account.transaction_items().length, 1, "The account should have 1 transaction item.");
        var item = account.transaction_items().first();
        equal(item.id(), 1, "The first transaction item should have the right account_id value.");
        equal(item.action(), 'debit', "The first transaction item should have the right action value.");
        equal(item.amount(), 1000, "The first transaction item should have the right amount value.");
        start();
      });
      equal(account.transaction_items().length, 0, "The transaction_items property should not load until accessed.");
    });
  });
  app.entities();
});
