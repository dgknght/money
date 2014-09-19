(function() {

  var ENTITY_ID = 573465;
  var CHECKING_ID = 2349876;
  var SALARY_ID = 8376;
  var TRANSACTION_ID = 4826;
  var ITEM_1_ID = 583726;
  var ITEM_2_ID = 4857;
  var ATTACHMENT_ID = 2945786;

  module('AttachmentViewModel', {
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
        responseText: [
          { id: CHECKING_ID, name: 'Checking', account_type: 'asset' },
          { id: SALARY_ID, name: 'Salary', account_type: 'income' },
        ]
      });
      $.mockjax({
        url: 'entities/' + ENTITY_ID + '/transactions.json?account_id=' + CHECKING_ID,
        responseText: [
          { 
            id: TRANSACTION_ID,
            description: 'Paycheck',
            transaction_date: '2014-01-01',
            items: [
              { id: ITEM_1_ID, account_id: CHECKING_ID, action: 'debit', amount: 1000 },
              { id: ITEM_2_ID, account_id: SALARY_ID, action: 'credit', amount: 1000 },
            ]
          },
        ]
      });
      $.mockjax({
        url: 'transactions/' + TRANSACTION_ID + '/attachments.json',
        responseText: [
          { id: ATTACHMENT_ID, name: 'paystub', content_type: 'image/png' },
        ]
      });
      $.mockjax({
        url: 'accounts/*/lots.json',
        responseText: []
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
      entity_id: ENTITY_ID,
      account_id: CHECKING_ID,
      transaction_item_id: ITEM_1_ID,
      attachment_id: ATTACHMENT_ID
    };
    getAttachment(app, ids, function(attachment) {
      ok(attachment.name, 'should be a property on the object.');
      if (attachment.name) {
        equal(attachment.name(), 'paystub', 'should have the correct value');
      }
      start();
    });
  });
})();
