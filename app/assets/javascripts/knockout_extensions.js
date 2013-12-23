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
  var result = ko.computed({
    read: function() {      
      if (result.state() == 'new') {
        result.state('loading');
        callback.call(context);
      }
      return value();
    },
    write: function(newValue) {
      result.state('loaded');
      value(newValue);
    },
    deferEvaluation: true
  }, this);
  result.state = ko.observable('new');
  result.refresh = function() { result.state('new'); };
  return result;
}

/*
 * Inline Editor
 */
ko.extenders.inlineEditor = function(target) {
  target.isEditing = ko.observable(false);

  target.edit = function() {
    target.isEditing(true);
  };

  target.stopEditing = function() {
    target.isEditing(false);
  };

  return target;
};

ko.bindingHandlers.inlineEditor = {
  init: function(element, valueAccessor) {
    var observable = valueAccessor(); // This assumes we've been bound to an observable property
    observable.extend({ inlineEditor: this });
  },
  update: function(element, valueAccessor) {
    var observable = valueAccessor();
    ko.bindingHandlers.css.update(element, function() {
      return { editing: observable.isEditing };
    });
    element.focus();
  }
};
