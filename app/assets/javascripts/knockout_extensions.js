//= require knockout-3.0.0

/*
 * Knockout extensions
 */
ko.lazyObservableArray = function(callback, context) {
  var value = ko.observableArray();
  var result = lazyComputed(callback, value, context);
  
  ko.utils.arrayForEach(["remove", "removeAll", "destroy", "destroyAll", "indexOf", "replace", "pop", "push", "reverse", "shift", "sort", "splice", "unshift", "slice"], function(methodName) {
    result[methodName] = function() {
      value[methodName].apply(value, arguments);
    };
  });
  
  return result;
};

function lazyComputed(callback, value, context) {
  var self = this
  this._context = context;
  this._callback = callback;
  
  var result = ko.computed({
    read: function() {      
      if (result.state() == 'new') {
        result.state('loading');
        self._callback.call(self._context);
      }
      return value();
    },
    write: function(newValue) {
      result.state('loaded');
      value(newValue);
    },
    deferEvaluation: true,
    owner: self
  });
  result.state = ko.observable('new');
  result.refresh = function() { result.state('new'); };
  return result;
}
