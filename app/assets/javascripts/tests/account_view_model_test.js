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
          id: 2,
          transaction_date: '2014-01-15',
          description: 'Salary',
          items: [
            { id: 1, account_id: 1, action: 'debit', amount: 1000 },
            { id: 2, account_id: 2, action: 'credit', amount: 1000 }
          ]
        },
        { 
          id: 1,
          transaction_date: '2014-01-01',
          description: 'Salary',
          items: [
            { id: 1, account_id: 1, action: 'debit', amount: 1000 },
            { id: 2, account_id: 2, action: 'credit', amount: 1000 }
          ]
        }
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest("validation", function() {
  var app = new MoneyApp();
  getEntity(app, 10, function(entity) {
    var account = new AccountViewModel({}, entity);
    account.name('Test');
    account.account_type('asset');
    ok(account.validate(), 'The account should be valid with a name and an account type');

    account.name(null);
    equal(account.validate(), false, 'The account should not be valid without a name');

    account.name('test');
    account.account_type(null);
    equal(account.validate(), false, 'The account should not be valid without an account type');

    account.account_type('not a valid type');
    equal(account.validate(), false, 'The account should not be valid without a valid account type');

    start();
  });
})
asyncTest("should have a transaction_items property", function() {
  expect(7);

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
        if (items.length != 2) return;

        equal(account.transaction_items().length, 2, "The account should have 2 transaction item.");
        var item = account.transaction_items().first();
        equal(item.id(), 1, "The first transaction item should have the right account_id value.");
        equal(item.action(), 'debit', "The first transaction item should have the right action value.");
        equal(item.polarizedAmount(), 1000, "The first transaction item should have the right amount value.");
        equal(item.transaction_item.transaction.transaction_date().toLocaleDateString(), '1/15/2014', "The transaction items should be in reverse chronological order.");
        start();
      });
      equal(account.transaction_items().length, 0, "The transaction_items property should not load until accessed.");
    });
  });
  app.entities();
});
