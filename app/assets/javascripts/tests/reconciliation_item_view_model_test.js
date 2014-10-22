(function() {
  var ENTITY_ID = 1;
  var CHECKING_ID = 2;
  var SALARY_ID = 3;
  var FIRST_TRANSACTION_ID = 4;
  var SECOND_TRANSACTION_ID = 5;
  var FIRST_TRANSACTION_ITEM_ID = 6;
  var SECOND_TRANSACTION_ITEM_ID = 7;
  var THIRD_TRANSACTION_ITEM_ID = 8;
  var FOURTH_TRANSACTION_ITEM_ID = 9;
  module('ReconciliationItemViewModel', {
    setup: function() {
      $.mockjaxClear();
      $.mockjax({
        url: 'entities.json',
        responseText: [{ id: ENTITY_ID, name: 'Personal' }]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/accounts.json',
        responseText: [
          { id: CHECKING_ID, name: 'Checking', account_type: 'asset', content_type: 'currency' },
          { id: SALARY_ID, name: 'Salary', account_type: 'income', content_type: 'currency' }
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
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + CHECKING_ID,
        responseText: [
          { id: FIRST_TRANSACTION_ID,
            description: 'Paycheck',
            transaction_date: '2014-01-01',
            items: [
              { id: FIRST_TRANSACTION_ITEM_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: SECOND_TRANSACTION_ITEM_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 },
            ]
          },
          { id: SECOND_TRANSACTION_ID,
            description: 'Paycheck',
            transaction_date: '2014-01-15',
            items: [
              { id: THIRD_TRANSACTION_ITEM_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: FOURTH_TRANSACTION_ITEM_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 },
            ]
          }
        ]
      });
    }
  });

  test('class', function() {
    ok(ReconciliationItemViewModel, 'The class must exist');
  });
  asyncTest('transaction_item', function() {
    expect(1);

    getTransactionItemRollup(new MoneyApp(), { entity_id: ENTITY_ID, account_id: CHECKING_ID, transaction_item_id: FIRST_TRANSACTION_ITEM_ID }, function(transaction_item_rollup) {
      var viewModel = new ReconciliationItemViewModel(transaction_item_rollup.transaction_item);
      ok(viewModel.transaction_item, 'should be a field on the item');
      start();
    });
  });
})();
