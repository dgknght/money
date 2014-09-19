(function() {
  var ENTITY_ID = 867675;
  var CHECKING_ID = 45123890;
  var SALARY_ID = 34986;
  var INCOME_TAX_ID = 234986;
  var TRANSACTION_ID = 98078967;
  var TRANSACTION_ITEM_1_ID = 76465;
  var TRANSACTION_ITEM_2_ID = 92346;

  module('TransactionViewModel', {
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
          { id: INCOME_TAX_ID, name: 'Income Tax', account_type: 'expense' }
        ]
      });
      $.mockjax({
        url: 'transactions/*/attachments.json',
        responseText: []
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + CHECKING_ID,
        responseText: [
          {
            id: TRANSACTION_ID,
            transaction_date: '2014-01-01',
            description: 'Salary',
            items: [
              { id: TRANSACTION_ITEM_1_ID, account_id: CHECKING_ID, action: 'debit', amount: "1000" },
              { id: TRANSACTION_ITEM_2_ID, account_id: SALARY_ID, action: 'credit', amount: "1000" }
            ]
          },
        ]
      });
      $.mockjax({
        url: 'accounts/*/lots.json',
        responseText: []
      });
      $.mockjax({
        url: 'transactions/*.json',
        type: 'PUT',
        responseText: []
      });
      $.mockjax({
        url: 'entities/*/commodities.json',
        responseText: []
      });
    }
  });
  asyncTest("transaction_date", function() {
    var app = new MoneyApp();
    getAccount(app, { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      getFromLazyLoadedCollection(account, "transaction_items", TRANSACTION_ITEM_1_ID, function(item) {
        ok(item.transaction_item, "The item rollup should reference the underlying transaction item.")
        ok(item.transaction_item.transaction, "The transaction item should reference the transaction.")

        var transaction = item.transaction_item.transaction;
        ok(transaction.transaction_date(), "The tranaction should have a transaction_date property.");
        equal(transaction.transaction_date().toLocaleDateString(), "1/1/2014", "The transaction_date property should have the correct value.");
        start();
      });
    });
  });
  asyncTest("creditAmount", function() {
    expect(2);

    var app = new MoneyApp();
    getAccount(app, { entity_id: ENTITY_ID, account_id: INCOME_TAX_ID }, function(account) {
      var transaction = {
        transaction_date: "2014-02-27",
        description: 'Paycheck', 
        items: [
          { account_id: CHECKING_ID, action: 'debit', amount: 1000 },
          { account_id: SALARY_ID, action: 'credit', amount: 1000 }
        ]
      };
      var viewModel = new TransactionViewModel(transaction, account.entity);

      equal(viewModel.creditAmount(), 1000, "creditAmount should be the sum of all the credit items.");

      var item = _.find(viewModel.items(), function(item) { return item.account_id() == SALARY_ID; });
      item.amount(987);

      equal(viewModel.creditAmount(), 987, "creditAmount should change when an item with a 'credit' action changes");

      start();
    });
  });
  asyncTest("formattedCreditAmount", function() {
    expect(2);

    var app = new MoneyApp();
    var account = getAccount(app, { entity_id: ENTITY_ID, account_id: INCOME_TAX_ID }, function(account) {
      var transaction = {
        transaction_date: "2014-02-27",
        description: 'Paycheck', 
        items: [
          { account_id: CHECKING_ID, action: 'debit', amount: 1000 },
          { account_id: SALARY_ID, action: 'credit', amount: 1000 }
        ]
      };
      var viewModel = new TransactionViewModel(transaction, account.entity);

      equal(viewModel.formattedCreditAmount(), '1,000.00', "creditAmount should be the sum of all the credit items.");

      var item = _.find(viewModel.items(), function(item) { return item.account_id() == SALARY_ID; });
      item.amount(987);

      equal(viewModel.formattedCreditAmount(), '987.00', "creditAmount should change when an item with a 'credit' action changes");

      start();
    });
  });
  asyncTest("debitAmount", function() {
    expect(2);

    var app = new MoneyApp();
    var account = getAccount(app, { entity_id: ENTITY_ID, account_id: INCOME_TAX_ID }, function(account) {
      var transaction = {
        transaction_date: "2014-02-27",
        description: 'Paycheck', 
        items: [
          { account_id: CHECKING_ID, action: 'debit', amount: 1000 },
          { account_id: SALARY_ID, action: 'credit', amount: 1000 }
        ]
      };
      var viewModel = new TransactionViewModel(transaction, account.entity);

      equal(viewModel.debitAmount(), 1000, "debitAmount should be the sum of all the debit items.");

      var item = _.find(viewModel.items(), function(item) { return item.account_id() == CHECKING_ID; });
      item.amount(123);

      equal(viewModel.debitAmount(), 123, "debitAmount should change when an item with a 'debit' action changes");

      start();
    });
  });
  asyncTest("formattedDebitAmount", function() {
    expect(2);

    var app = new MoneyApp();
    var account = getAccount(app, { entity_id: ENTITY_ID, account_id: INCOME_TAX_ID }, function(account) {
      var transaction = {
        transaction_date: "2014-02-27",
        description: 'Paycheck', 
        items: [
          { account_id: CHECKING_ID, action: 'debit', amount: 1000 },
          { account_id: SALARY_ID, action: 'credit', amount: 1000 }
        ]
      };
      var viewModel = new TransactionViewModel(transaction, account.entity);

      equal(viewModel.formattedDebitAmount(), '1,000.00', "debitAmount should be the sum of all the debit items.");

      var item = _.find(viewModel.items(), function(item) { return item.account_id() == CHECKING_ID; });
      item.amount(123);

      equal(viewModel.formattedDebitAmount(), '123.00', "debitAmount should change when an item with a 'debit' action changes");

      start();
    });
  });
  asyncTest("validation", function() {
    expect(6);

    var app = new MoneyApp();
    // I get the account here because the account list must be loaded for the transaction item to work
    var account = getAccount(app, { entity_id: ENTITY_ID, account_id: INCOME_TAX_ID }, function(account) {
      var transaction = {
        transaction_date: "2014-02-27",
        description: 'Paycheck', 
        items: [
          { account_id: CHECKING_ID, action: 'debit', amount: 1000 },
          { account_id: SALARY_ID, action: 'credit', amount: 1000 }
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

      var newItem = viewModel.addTransactionItem();
      newItem.account_id(INCOME_TAX_ID);
      newItem.action('debit');
      newItem.amount(100);

      equal(viewModel.validate(), false, "The model should not be valid if the sum of credits does not equal the sum of debits.");

      var checkingItem = _.find(viewModel.items(), function(item) { return item.account_id() == CHECKING_ID});
      checkingItem.amount(900);

      ok(viewModel.validate(), "The model should be valid if the sum of credits and debits are the same.");

      start();
    });
  })
  asyncTest("addTransactionItem", function() {
    expect(3);

    var app = new MoneyApp();
    getTransaction(app, { entity_id: ENTITY_ID, account_id: CHECKING_ID, transaction_item_id: TRANSACTION_ITEM_1_ID }, function(transaction) {
      ok(transaction.addTransactionItem, "The object should have a method called 'addTransactionItem'");
      if (transaction.addTransactionItem) {
        var before = transaction.items().length;
        var newItem = transaction.addTransactionItem();
        ok(newItem, "It should not return null.");
        var after = transaction.items().length;
        equal(after - before, 1, "It should add an item to the items collection.");
      }
      start()
    });
  });
  asyncTest('newAttachment', function() {
    expect(3);

    var app = new MoneyApp();
    getTransaction(app, { entity_id: ENTITY_ID, account_id: CHECKING_ID, transaction_item_id: TRANSACTION_ITEM_1_ID }, function(transaction) {
      ok(transaction.newAttachment, 'The object should have a method called "newAttachment"');
      if (transaction.newAttachment) {
      transaction.newAttachment();
      ok(app.editAttachment, 'The application object should have a method called "editAttachment"');
        if (app.editAttachment) {
          ok(app.editAttachment(), 'The application object editAttachment method should not return null after calling newAttachment on a transaction.');
        }
      }
      start();
    });
  });
})();
