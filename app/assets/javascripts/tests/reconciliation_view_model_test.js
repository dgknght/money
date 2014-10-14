(function() {
  var ENTITY_ID             =  1;
  var CHECKING_ID           =  2;
  var SALARY_ID             =  3;
  var IRA_ID                =  4;
  var KSS_ACCOUNT_ID        =  5;
  var PRICE_ID              =  6;
  var KSS_ID                =  7;
  var SAVINGS_ID            =  8;
  var CAR_SAVINGS_ID        =  9;
  var RESERVE_SAVINGS_ID    = 10;
  var GROCERIES_ID          = 11;
  var LOT_ID                = 12;
  var TRANSACTION_1_ID      = 13;
  var TRANSACTION_2_ID      = 14;
  var TRANSACTION_3_ID      = 15;
  var TRANSACTION_ITEM_1_ID = 16;
  var TRANSACTION_ITEM_2_ID = 17;
  var TRANSACTION_ITEM_3_ID = 18;
  var TRANSACTION_ITEM_4_ID = 19;
  var TRANSACTION_ITEM_5_ID = 20;
  var TRANSACTION_ITEM_6_ID = 21;

  var ACCOUNTS = [
    { id: CHECKING_ID, name: 'Checking', account_type: 'asset', content_type: 'currency', balance: 200 },
    { id: SALARY_ID, name: 'Salary', account_type: 'income', content_type: 'currency', balance: 0 },
    { id: IRA_ID, name: 'IRA', account_type: 'asset', content_type: 'commodities', balance: 1000 },
    { id: KSS_ACCOUNT_ID, name: 'KSS', account_type: 'asset', content_type: 'commodity', balance: 1000 },
    { id: SAVINGS_ID, name: 'Savings', account_type: 'asset', content_type: 'currency', balance: 0 },
    { id: CAR_SAVINGS_ID, name: 'Car', account_type: 'asset', content_type: 'currency', balance: 15000, parent_id: SAVINGS_ID },
    { id: RESERVE_SAVINGS_ID, name: 'Reserve', account_type: 'asset', content_type: 'currency', balance: 24000, parent_id: SAVINGS_ID }
  ];
  module('ReconiliationViewModel', {
    setup: function() {
      $.mockjaxClear();
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'Personal' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: ACCOUNTS
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + CHECKING_ID,
        responseText: [
          {
            id: TRANSACTION_1_ID,
            transaction_date: '2014-01-15',
            description: 'Paycheck',
            items: [
              { id: TRANSACTION_ITEM_1_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: TRANSACTION_ITEM_2_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 }
            ]
          },
          {
            id: TRANSACTION_2_ID,
            transaction_date: '2014-01-15',
            description: 'Paycheck',
            items: [
              { id: TRANSACTION_ITEM_3_ID, account_id: GROCERIES_ID, action: 'debit', amount: 100 },
              { id: TRANSACTION_ITEM_4_ID, account_id: CHECKING_ID, action: 'credit', amount: 100 }
            ]
          },
          {
            id: TRANSACTION_3_ID,
            transaction_date: '2014-01-01',
            description: 'Paycheck',
            items: [
              { id: TRANSACTION_ITEM_5_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: TRANSACTION_ITEM_6_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 }
            ]
          }
        ]
      });
      $.mockjax({
        url: 'accounts/' + CHECKING_ID + '/reconciliations/new.json',
        responseText: { previous_balance: 1000 }
      });
      $.mockjax({
        url: 'accounts/*/lots.json',
        responseText: []
      });
      $.mockjax({
        url: 'transactions/*/attachments.json',
        responseText: []
      });
    }
  });
  asyncTest("closing_balance", function() {
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      account.reconcile(function(reconciliation) {
        ok(reconciliation.closing_balance, 'The instance should have a closing_balance method');
        if (reconciliation.closing_balance) {
          equal(reconciliation.closing_balance(), 0, 'The closing_balance method should return 0 by default');
        }
        start();
      });
    });
  });
  asyncTest("previous_balance", function() {
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      account.reconcile(function(reconciliation) {
        ok(reconciliation.previous_balance, 'The instance should have a previous_balance method');
        if (reconciliation.previous_balance) {
          equal(reconciliation.previous_balance(), 1000, 'The previous_balance method should return the correct value');
        }
        start();
      });
    });
  });
  asyncTest("reconciliation_date", function() {
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      account.reconcile(function(reconciliation) {
        ok(reconciliation.reconciliation_date, 'The instance should have a reconciliation_date method');
        if (reconciliation.reconciliation_date) {
          equal(reconciliation.reconciliation_date().toLocaleDateString(), new Date().toLocaleDateString(), 'The reconciliation_date method should return the current date by default');
        }
        start();
      });
    });
  });
  asyncTest("validation", function() {
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      account.reconcile(function(reconciliation) {
        ok(false, 'need to write the test');
        start();
      });
    });
  });
})();
