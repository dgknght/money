module('TransactionViewModel', {
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
        { id: 3, name: 'Income Tax', account_type: 'expense' }
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest("creditAmount", function() {
  expect(2);

  var app = new MoneyApp();
  var account = getAccount(app, { entity_id: 10, account_id: 3 }, function(account) {
    var transaction = {
      transaction_date: new Date(),
      description: 'Paycheck', 
      items: [
        { account_id: 1, action: 'debit', amount: 1000 },
        { account_id: 2, action: 'credit', amount: 1000 }
      ]
    };
    var viewModel = new TransactionViewModel(transaction, account.entity);

    equal(viewModel.creditAmount(), 1000, "creditAmount should be the sum of all the credit items.");

    var item = _.find(viewModel.items(), function(item) { return item.account_id() == 2; });
    item.amount(987);

    equal(viewModel.creditAmount(), 987, "creditAmount should change when an item with a 'credit' action changes");

    start();
  });
});
asyncTest("formattedCreditAmount", function() {
  expect(2);

  var app = new MoneyApp();
  var account = getAccount(app, { entity_id: 10, account_id: 3 }, function(account) {
    var transaction = {
      transaction_date: new Date(),
      description: 'Paycheck', 
      items: [
        { account_id: 1, action: 'debit', amount: 1000 },
        { account_id: 2, action: 'credit', amount: 1000 }
      ]
    };
    var viewModel = new TransactionViewModel(transaction, account.entity);

    equal(viewModel.formattedCreditAmount(), '1,000.00', "creditAmount should be the sum of all the credit items.");

    var item = _.find(viewModel.items(), function(item) { return item.account_id() == 2; });
    item.amount(987);

    equal(viewModel.formattedCreditAmount(), '987.00', "creditAmount should change when an item with a 'credit' action changes");

    start();
  });
});
asyncTest("debitAmount", function() {
  expect(2);

  var app = new MoneyApp();
  var account = getAccount(app, { entity_id: 10, account_id: 3 }, function(account) {
    var transaction = {
      transaction_date: new Date(),
      description: 'Paycheck', 
      items: [
        { account_id: 1, action: 'debit', amount: 1000 },
        { account_id: 2, action: 'credit', amount: 1000 }
      ]
    };
    var viewModel = new TransactionViewModel(transaction, account.entity);

    equal(viewModel.debitAmount(), 1000, "debitAmount should be the sum of all the debit items.");

    var item = _.find(viewModel.items(), function(item) { return item.account_id() == 1; });
    item.amount(123);

    equal(viewModel.debitAmount(), 123, "debitAmount should change when an item with a 'debit' action changes");

    start();
  });
});
asyncTest("formattedDebitAmount", function() {
  expect(2);

  var app = new MoneyApp();
  var account = getAccount(app, { entity_id: 10, account_id: 3 }, function(account) {
    var transaction = {
      transaction_date: new Date(),
      description: 'Paycheck', 
      items: [
        { account_id: 1, action: 'debit', amount: 1000 },
        { account_id: 2, action: 'credit', amount: 1000 }
      ]
    };
    var viewModel = new TransactionViewModel(transaction, account.entity);

    equal(viewModel.formattedDebitAmount(), '1,000.00', "debitAmount should be the sum of all the debit items.");

    var item = _.find(viewModel.items(), function(item) { return item.account_id() == 1; });
    item.amount(123);

    equal(viewModel.formattedDebitAmount(), '123.00', "debitAmount should change when an item with a 'debit' action changes");

    start();
  });
});
asyncTest("validation", function() {
  expect(6);

  var app = new MoneyApp();
  // I get the account here because the account list must be loaded for the transaction item to work
  var account = getAccount(app, { entity_id: 10, account_id: 3 }, function(account) {
    var transaction = {
      transaction_date: new Date(),
      description: 'Paycheck', 
      items: [
        { account_id: 1, action: 'debit', amount: 1000 },
        { account_id: 2, action: 'credit', amount: 1000 }
      ]
    };
    var viewModel = new TransactionViewModel(transaction, account.entity);
    ok(viewModel.validate(), "The model should be valid with a transaction date, description, and balanced items.");

    viewModel.transaction_date(null);
    equal(viewModel.validate(), false, "The model should not be valid without a transaction date.");

    viewModel.transaction_date("not a date");
    equal(viewModel.validate(), false, "The model should not be valid with an invalid transaction date.");

    viewModel.transaction_date(new Date());

    viewModel.description(null);
    equal(viewModel.validate(), false, "The model should not be valid without a description.");
    viewModel.description('test');

    var newItem = new TransactionItemViewModel({ account_id: 3, action: 'debit', amount: 100 }, viewModel);
    viewModel.items.push(newItem);

    equal(viewModel.validate(), false, "The model should not be valid if the sum of credits does not equal the sum of debits.");

    var checkingItem = _.find(viewModel.items(), function(item) { return item.account_id() == 1});
    checkingItem.amount(900);

    ok(viewModel.validate(), "The model should be valid if the sum of credits and debits are the same.");

    start();
  });
})
