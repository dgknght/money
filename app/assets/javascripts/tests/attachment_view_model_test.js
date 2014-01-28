module('AttachmentViewModel', {
  setup: function() {
    $.mockjax({
      url: 'entities.json',
      responseText: [
        { id: 11, name: 'Personal' }
      ]
    });
    $.mockjax({
      url: 'entities/11/accounts.json',
      responseText: [
        { id: 21, name: 'Checking', account_type: 'asset' },
        { id: 22, name: 'Salary', account_type: 'income' },
      ]
    });
    $.mockjax({
      url: 'entities/11/transactions.json?account_id=21',
      responseText: [
        { 
          id: 31, 
          description: 'Paycheck',
          transaction_date: '2014-01-01',
          items: [
            { id: 41, account_id: 21, action: 'debit', amount: 1000 },
            { id: 42, account_id: 22, action: 'credit', amount: 1000 },
          ]
        },
      ]
    });
    $.mockjax({
      url: 'transactions/31/attachments.json',
      responseText: [
        { id: 51, name: 'paystub', content_type: 'image/png' },
      ]
    });
  },
  teardown: function() {
    $.mockjaxClear();
  }
});
asyncTest('name', function() {
  expect(2);

  var app = new MoneyApp();
  var ids = {
    entity_id: 11,
    account_id: 21,
    transaction_item_id: 41,
    attachment_id: 51
  };
  getAttachment(app, ids, function(attachment) {
    ok(attachment.name, 'should be a property on the object.');
    if (attachment.name) {
      equal(attachment.name(), 'paystub', 'should have the correct value');
    }
    start();
  });
});
