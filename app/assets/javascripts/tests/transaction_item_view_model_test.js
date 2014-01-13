module('TransactionItemViewModel', {
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
        { id: 2, name: 'Salary', account_type: 'income' }
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
