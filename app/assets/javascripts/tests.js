//= require single_page
//= require lib/qunit-1.13.0
//= require lib/jquery.mockjax

//= require tests/service_entity_test.js
//= require tests/money_app_test.js
//= require tests/entity_view_model_test.js
//= require tests/account_view_model_test.js
//= require tests/transaction_view_model_test.js
//= require tests/attachment_view_model_test.js
//= require tests/transaction_item_view_model_test.js
//= require tests/transaction_item_rollup_view_model_test.js
//= require tests/new_transaction_item_view_model_test.js
//= require tests/commodity_view_model_test.js
//= require tests/lot_view_model_test.js
//= require tests/price_view_model_test.js
//= require tests/new_commodity_transaction_view_model_test.js
//= require tests/reconciliation_view_model_test.js
//= require tests/reconciliation_item_view_model_test.js

$.mockjaxSettings.throwUnmocked = true;
$.mockjaxSettings.responseTime = 50;

function getFromLazyLoadedCollection(obj, property, id, callback) {
  var timeout = window.setTimeout(function() {
    throw "getFromLazyLoadedCollection failed: unable to find item with id=" + id + " in the " + property + " collection.";
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

function getPrice(app, keys, callback) {
  getCommodity(app, keys, function(commodity) {
    getFromLazyLoadedCollection(commodity, 'prices', keys.price_id, callback);
  });
}

function getCommodity(app, keys, callback) {
  getEntity(app, keys.entity_id, function(entity) {
    getFromLazyLoadedCollection(entity, 'commodities', keys.commodity_id, callback);
  });
}

function getLot(app, keys, callback) {
  getAccount(app, keys, function(account) {
    getFromLazyLoadedCollection(account, 'lots', keys.lot_id, callback);
  });
}

function getAccount(app, keys, callback) {
  getEntity(app, keys.entity_id, function(entity) {
    getFromLazyLoadedCollection(entity, 'accounts', keys.account_id, callback);
  });
}

function getTransactionItemRollup(app, ids, callback) {
  getAccount(app, ids, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', ids.transaction_item_id, callback);
  });
}

function getTransaction(app, ids, callback) {
  getAccount(app, ids, function(account) {
    getFromLazyLoadedCollection(account, 'transaction_items', ids.transaction_item_id, function(rollup) {
      callback(rollup.transaction_item.transaction);
    });
  });
}

function getEntity(app, entity_id, callback) {
  getFromLazyLoadedCollection(app, 'entities', entity_id, callback);
}

function getAttachment(app, ids, callback) {
  getTransactionItemRollup(app, ids, function(item) {
    getFromLazyLoadedCollection(item, 'attachments', ids.attachment_id, callback);
  });
}
