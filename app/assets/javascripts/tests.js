//= require single_page
//= require lib/qunit-1.13.0
//= require lib/jquery.mockjax

//= require tests/service_entity_test.js
//= require tests/money_app_test.js
//= require tests/entity_view_model_test.js
//= require tests/account_view_model_test.js
//= require tests/transaction_view_model_test.js
//= require tests/transaction_item_view_model_test.js
//= require tests/transaction_item_rollup_view_model_test.js
//= require tests/new_transaction_item_view_model_test.js

function getFromLazyLoadedCollection(obj, property, id, callback) {
  var timeout = window.setTimeout(function() {
    throw "getFromLazyLoadedCollection failed: unable to find item with id=" + id + " in the collection.";
  }, 2000);

  var subscription = obj[property].subscribe(function(values) {
    var result = _.find(values, function(value){ return value.id() == id; });
    if (result != null) {
      window.clearTimeout(timeout);
      subscription.dispose();
      callback(result);
    }
  });
  obj[property]();
}

function getAccount(app, keys, callback) {
  getEntity(app, keys.entity_id, function(entity) {
    getFromLazyLoadedCollection(entity, 'accounts', keys.account_id, callback);
  });
}

function getTransactionItem(app, keys, callback) {
  getAccount(app, keys, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', keys.transaction_item_id, callback);
  });
}

function getEntity(app, entity_id, callback) {
  getFromLazyLoadedCollection(app, 'entities', entity_id, callback);
}

