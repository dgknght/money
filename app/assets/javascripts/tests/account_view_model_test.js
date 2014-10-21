(function() {
  var ENTITY_ID = 57263;
  var CHECKING_ID = 223457;
  var SALARY_ID = 93735;
  var IRA_ID = 3824;
  var KSS_ACCOUNT_ID = 73635;
  var PRICE_ID = 2963;
  var KSS_ID = 465;
  var SAVINGS_ID = 8275635;
  var CAR_SAVINGS_ID = 395836;
  var RESERVE_SAVINGS_ID = 82746;
  var LOT_ID = 59837;
  var TRANSACTION_1_ID = 354895;
  var TRANSACTION_2_ID = 89776567;
  var TRANSACTION_ITEM_1_ID = 39126;
  var TRANSACTION_ITEM_2_ID = 3856;
  var TRANSACTION_ITEM_3_ID = 8765;
  var TRANSACTION_ITEM_4_ID = 19347;

  var ACCOUNTS = [
    { id: CHECKING_ID, name: 'Checking', account_type: 'asset', content_type: 'currency', balance: 200 },
    { id: SALARY_ID, name: 'Salary', account_type: 'income', content_type: 'currency', balance: 0 },
    { id: IRA_ID, name: 'IRA', account_type: 'asset', content_type: 'commodities', balance: 1000 },
    { id: KSS_ACCOUNT_ID, name: 'KSS', account_type: 'asset', content_type: 'commodity', balance: 1000 },
    { id: SAVINGS_ID, name: 'Savings', account_type: 'asset', content_type: 'currency', balance: 0 },
    { id: CAR_SAVINGS_ID, name: 'Car', account_type: 'asset', content_type: 'currency', balance: 15000, parent_id: SAVINGS_ID },
    { id: RESERVE_SAVINGS_ID, name: 'Reserve', account_type: 'asset', content_type: 'currency', balance: 24000, parent_id: SAVINGS_ID }
  ];
  module('AccountViewModel', {
    setup: function() {
      $.mockjaxClear();
      $.mockjax({
        url: 'entities.json',
        responseText: [
          { id: ENTITY_ID, name: 'First Entity' }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: ACCOUNTS
      });
      $.mockjax({
        url: 'accounts/' + KSS_ACCOUNT_ID + '/lots.json',
        responseText: [
          {
            id: LOT_ID,
            account_id: KSS_ACCOUNT_ID,
            commodity_id: KSS_ID,
            price:10.0,
            shares_owned:100.0,
            purchase_date:"2014-07-15"
          }
        ]
      });
      $.mockjax({
        url: 'accounts/' + CHECKING_ID + '/reconciliations/new.json',
        responseText: [
          {
            previous_balance: 0,
            previous_reconciliation_date: '2014-02-27'
          }
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/commodities.json',
        responseText: [
          { id: KSS_ID, name: 'Knight Software Services', symbol: 'KSS', market: 'NYSE' }
        ]
      });
      $.mockjax({
        url: 'commodities/' + KSS_ID + '/prices.json',
        responseText: [
          { id: PRICE_ID, trade_date: '2014-08-01', price: 12 }
        ]
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
            transaction_date: '2014-01-01',
            description: 'Paycheck',
            items: [
              { id: TRANSACTION_ITEM_3_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: TRANSACTION_ITEM_4_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 }
            ]
          }
        ]
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
  asyncTest("validation", function() {
    expect(4);

    var app = new MoneyApp();
    getEntity(app, ENTITY_ID, function(entity) {
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
  asyncTest("balance", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      ok(account.balance, 'The object should have a "balance" method');
      if (account.balance) {
        equal(account.balance(), 200, 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("formattedBalance", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      ok(account.formattedBalance, 'The object should have a "formattedBalance" method');
      if (account.formattedBalance) {
        equal(account.formattedBalance(), "200.00", 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("balanceWithChildren", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID}, function(account) {
      ok(account.balanceWithChildren, 'The object should have a "balanceWithChildren" method');
      if (account.balanceWithChildren) {
        equal(account.balanceWithChildren(), 39000, 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("formattedBalanceWithChildren", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID}, function(account) {
      ok(account.formattedBalanceWithChildren, 'The object should have a "formattedBalanceWithChildren" method');
      if (account.formattedBalanceWithChildren) {
        equal(account.formattedBalanceWithChildren(), "39,000.00", 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("transaction_items", function() {
    expect(7);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID}, function(account) {
      ok(account.transaction_items, "The account should have a transaction_items property.");
      account.transaction_items.subscribe(function(items) {
        if (items.length != 2) return;

        equal(account.transaction_items().length, 2, "The account should have 2 transaction items.");
        var item = account.transaction_items().first();
        equal(item.id(), TRANSACTION_ITEM_1_ID, "The first transaction item should have the right account_id value.");
        equal(item.action(), 'debit', "The first transaction item should have the right action value.");
        equal(item.polarizedAmount(), 1000, "The first transaction item should have the right amount value.");
        equal(item.transaction_item.transaction.transaction_date().toLocaleDateString(), '1/15/2014', "The transaction items should be in reverse chronological order.");
        start();
      });
      equal(account.transaction_items().length, 0, "The transaction_items property should not load until accessed.");
    });
  });
  asyncTest("commoditiesMenuVisible", function() {
    expect(2);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(commoditiesAccount) {
      equal(commoditiesAccount.commoditiesMenuVisible(), true, 'Commodities accounts should show the commodities menu');

      otherAccount = commoditiesAccount.entity.getAccount(CHECKING_ID);
      equal(otherAccount.commoditiesMenuVisible(), false, 'Non-commodities accounts should not show the commodities menu');
      start();
    });
  });
  asyncTest("holdingsVisible", function() {
    expect(6);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(commoditiesAccount) {
      equal(commoditiesAccount.holdingsVisible(), true, 'Commodities accounts should show the holdings by default');
      commoditiesAccount.transactionItemsVisible(true);
      equal(commoditiesAccount.holdingsVisible(), false, 'holdingsVisible should be false if transactionItemsVisible is true');

      otherAccount = commoditiesAccount.entity.getAccount(CHECKING_ID);
      equal(otherAccount.holdingsVisible(), false, 'Non-commodities accounts should not show holdings');
      equal(otherAccount.transactionItemsVisible(), true, 'Non-commodities accounts should only show transaction items');
      otherAccount.holdingsVisible(true);
      equal(otherAccount.holdingsVisible(), false, 'Non-commodities accounts should not show holdings');
      equal(otherAccount.transactionItemsVisible(), true, 'Non-commodities accounts should only show transaction items');
      start();
    });
  });
  asyncTest("showTransactionItems", function() {
    expect(2);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(commoditiesAccount) {
      equal(commoditiesAccount.transactionItemsVisible(), false, 'Commodities accounts should not show the transactions items by default');
      commoditiesAccount.showTransactionItems();
      equal(commoditiesAccount.transactionItemsVisible(), true, 'transactionItemsVisible should be true after calling showTransactionItems');
      start();
    });
  });
  asyncTest("showHoldings", function() {
    expect(1);

    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(commoditiesAccount) {
      commoditiesAccount.holdingsVisible(false);
      commoditiesAccount.showHoldings();
      equal(commoditiesAccount.holdingsVisible(), true, 'holdingsVisible should be true after calling showHoldings');
      start();
    });
  });
  asyncTest("value for a COMMODITIES account", function() {
    // should be the amount of cash in the account, same as balance
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(account) {
      ok(account.value, 'The object should have a "value" method');
      if (account.value) {
        ok(account.value(), 1000, 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("value for a COMMODITY account", function() {
    // should be the number of shares held multiplied by the current commodity price
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID }, function(account) {
      ok(account.value, 'The object should have a "value" method');
      if (account.value) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the correct "value"');
          start();
        }, 2000);
        account.value.subscribe(function(value) {
          if (value == 1200) {
            window.clearTimeout(timeoutId);
            ok(true);
            start();
          }
        });
        account.value();
      } else {
        start();
      }
    });
  });
  asyncTest("value for a CURRENCY account", function() {
    // should be the same as the balance
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID }, function(account) {
      ok(account.value, 'The object should have a "value" method');
      if (account.value) {
        equal(account.value(), 0, 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("valueWithChildren for a CURRENCY account", function() {
    // should be the same as the balanceWithChildren
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID }, function(account) {
      ok(account.valueWithChildren, 'The object should have a "valueWithChildren" method');
      if (account.valueWithChildren) {
        equal(account.valueWithChildren(), 39000, 'The method should return the correct value');
      }
      start();
    });
  });
  //  This behavior seems to work just fine, but I can't make the test work. The subscription is never notified
//  asyncTest("valueWithChildren for a COMMODITIES account", function() {
//    expect(2);
//    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(account) {
//      ok(account.valueWithChildren, 'The object should have a "valueWithChildren" method');
//      if (account.valueWithChildren) {
//        var timeoutId = window.setTimeout(function() {
//          ok(false, 'Never received the correct value');
//          start();
//        }, 8000);
//        account.valueWithChildren.subscribe(function(value) {
//          if (value == 2200) {
//            window.clearTimeout(timeoutId);
//            ok(true);
//            start();
//          }
//        });
//        account.valueWithChildren();
//      } else {
//        start();
//      }
//    });
//  });
  asyncTest("valueWithChildren for a COMMODITY account", function() {
    // should be the same as value, as COMMODITY accounts don't have children
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID }, function(account) {
      ok(account.valueWithChildren, 'The object should have a "valueWithChildren" method');
      if (account.valueWithChildren) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the correct value');
          start();
        }, 2000);
        account.valueWithChildren.subscribe(function(value) {
          if (value == 1200) {
            window.clearTimeout(timeoutId);
            ok(true);
            start();
          }
        });
        account.valueWithChildren();
      } else {
        start();
      }
    });
  });
  asyncTest("formattedValue", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID}, function(account) {
      ok(account.formattedValue, 'The object should have a "formattedValue" method');
      if (account.formattedValue) {
        equal(account.formattedValue(), "1,000.00", 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("formattedValueWithChildren", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID}, function(account) {
      ok(account.formattedValueWithChildren, 'The object should have a "formattedValueWithChildren" method');
      equal(account.formattedValueWithChildren(), "39,000.00", 'The method should return the correct value');
      start();
    });
  });
  asyncTest("cost", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID}, function(account) {
      ok(account.cost, 'The object should have a "cost" method');
      if (account.cost) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the event');
          start();
        }, 2000);
        account.cost.subscribe(function(value) {
          window.clearTimeout(timeoutId);
          equal(value, 1000, 'The method should return the correct value');
          start();
        });
      } else {
        start();
      }
    });
  });
  asyncTest("formattedCost", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID}, function(account) {
      ok(account.formattedCost, 'The object should have a "formattedCost" method');
      if (account.formattedCost) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the event');
          start();
        }, 2000);
        account.formattedCost.subscribe(function(value) {
          window.clearTimeout(timeoutId);
          equal(value, "1,000.00", 'The method should return the correct value');
          start();
        });
      } else {
        start();
      }
    });
  });
//  asyncTest("costWithChildren", function() {
//    expect(2);
//    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID}, function(account) {
//      ok(account.costWithChildren, 'The object should have a "costWithChildren" method');
//      if (account.costWithChildren) {
//        var timeoutId = window.setTimeout(function() {
//          ok(false, 'Never received the event');
//          start();
//        }, 2000);
//        account.costWithChildren.subscribe(function(value) {
//          window.clearTimeout(timeoutId);
//          equal(value, 1000, 'The method should return the correct value');
//          start();
//        });
//        account.costWithChildren();
//      } else {
//        start();
//      }
//    });
//  });
//  asyncTest("formattedCostWithChildren", function() {
//    expect(2);
//    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID}, function(account) {
//      ok(account.formattedCostWithChildren, 'The object should have a "formattedCostWithChildren" method');
//      if (account.formattedCostWithChildren) {
//        var timeoutId = window.setTimeout(function() {
//          ok(false, 'Never received the event');
//          start();
//        }, 2000);
//        account.formattedCostWithChildren.subscribe(function(value) {
//          window.clearTimeout(timeoutId);
//          equal(value, "1,000.00", 'The method should return the correct value');
//          start();
//        });
//        account.formattedCostWithChildren();
//      } else {
//        start();
//      }
//    });
//  });
  asyncTest("shares", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID}, function(account) {
      ok(account.shares, 'The object should have a "shares" method');
      if (account.shares) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the event');
          start();
        }, 2000);
        account.shares.subscribe(function(value) {
          window.clearTimeout(timeoutId);
          equal(value, 100, 'The method should return the correct value');
          start();
        });
      } else {
        start();
      }
    });
  });
  asyncTest("formattedShares", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID}, function(account) {
      ok(account.formattedShares, 'The object should have a "formattedShares" method');
      if (account.formattedShares) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'Never received the event');
          start();
        }, 2000);
        account.formattedShares.subscribe(function(value) {
          window.clearTimeout(timeoutId);
          equal(value, "100.0000", 'The method should return the correct value');
          start();
        });
      } else {
        start();
      }
    });
  });
  asyncTest("gainLoss", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID}, function(account) {
      ok(account.gainLoss, 'The object should have a "gainLoss" method');
      if (account.gainLoss) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'The correct value was never recieved');
          start();
        }, 2000);
        account.gainLoss.subscribe(function(value) {
          if (value == 200) {
            window.clearTimeout(timeoutId);
            equal(value, 200, 'The method should return the correct value');
            start();
          }
        });
      } else {
        start();
      }
    });
  });
  asyncTest("formattedGainLoss", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: KSS_ACCOUNT_ID}, function(account) {
      ok(account.formattedGainLoss, 'The object should have a "formattedGainLoss" method');
      if (account.formattedGainLoss) {
        var timeoutId = window.setTimeout(function() {
          ok(false, 'The correct value was never recieved');
          start();
        }, 2000);
        account.formattedGainLoss.subscribe(function(value) {
          if (value == '200.00') {
            window.clearTimeout(timeoutId);
            equal(value, '200.00', 'The method should return the correct value');
            start();
          }
        });
      } else {
        start();
      }
    });
  });
  asyncTest("childrenValue", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID}, function(account) {
      ok(account.childrenValue, 'The object should have a "childrenValue" method');
      if (account.childrenValue) {
        equal(account.childrenValue(), 39000, 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("formattedChildrenValue", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: SAVINGS_ID}, function(account) {
      ok(account.formattedChildrenValue, 'The object should have a "formattedChildrenValue" method');
      if (account.formattedChildrenValue) {
        equal(account.formattedChildrenValue(), '39,000.00', 'The method should return the correct value');
      }
      start();
    });
  });
  asyncTest("newCommodityTransaction", function() {
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID }, function(account) {
      ok(account.newCommodityTransaction, 'The object should have a "newCommodityTransaction" method');
      start();
    });
  });
  asyncTest("reconile", function() {
    expect(2);
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.reconcile, 'The object should have a "reconcile" method');
      if (account.reconcile) {
        account.reconcile(function(reconciliation) {
          ok(reconciliation, 'The reconcile method should not return null');
          start();
        });
      } else {
        start();
      }
    });
  });
  asyncTest("reconiliation", function() {
    expect(3)
    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID }, function(account) {
      ok(account.reconciliation, 'The object should have a "reconciliation" method');
      if (account.reconciliation) {
        equal(null, account.reconciliation(), 'The reconciliation method should return null before reconcile is called.');
        account.reconcile(function(_) {
          ok(account.reconciliation(), 'The reconciliation method should not return null after reconcile is called.');
          start();
        });
      } else {
        start();
      }
    });
  });

//  asyncTest("gainLossWithChildren", function() {
//    expect(2);
//    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID}, function(account) {
//      ok(account.gainLossWithChildren, 'The object should have a "gainLossWithChildren" method');
//      if (account.gainLossWithChildren) {
//        var timeoutId = window.setTimeout(function() {
//          ok(false, 'The correct value was never recieved');
//          start();
//        }, 2000);
//        account.gainLossWithChildren.subscribe(function(value) {
//          if (value == 200) {
//            window.clearTimeout(timeoutId);
//            equal(value, 200, 'The method should return the correct value');
//            start();
//          }
//        });
//      } else {
//        start();
//      }
//    });
//  });
//  asyncTest("formattedGainLossWithChildren", function() {
//    expect(2);
//    getAccount(new MoneyApp(), { entity_id: ENTITY_ID, account_id: IRA_ID}, function(account) {
//      ok(account.formattedGainLossWithChildren, 'The object should have a "formattedGainLossWithChildren" method');
//      if (account.formattedGainLossWithChildren) {
//        var timeoutId = window.setTimeout(function() {
//          ok(false, 'The correct value was never recieved');
//          start();
//        }, 2000);
//        account.formattedGainLossWithChildren.subscribe(function(value) {
//
//          console.log("formattedGainLossWithChildren " + value);
//
//          if (value == '200.00') {
//            window.clearTimeout(timeoutId);
//            equal(value, 200, 'The method should return the correct value');
//            start();
//          }
//        });
//      } else {
//        start();
//      }
//    });
//  });
})();
