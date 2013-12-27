//= require knockout-3.0.0.debug

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
 * hidden binding handler
 */
ko.bindingHandlers.hidden = {
  update: function(element, valueAccessor) {
    ko.bindingHandlers.visible.update(element, function() {
      return !ko.utils.unwrapObservable(valueAccessor());
    });
  }
};

/*
 * Inline Editor
 */
ko.extenders.inlineEditor = function(target) {
  target.isEditing = ko.observable(false);

  target.edit = function() {
    target.previousValue = target();
    target.isEditing(true);
  };

  target.finishEditing = function() {
    target.previousValue = null;
    target.isEditing(false);
  };

  target.abortEditing = function() {
    target.previousValue = null;
    target.isEditing(false);
    target(target.previousValue);
  };

  return target;
};

ko.bindingHandlers.inlineEditor = {
  init: function(element, valueAccessor, allBindings) {
    var observable = valueAccessor(); // This assumes we've been bound to an observable property
    observable.extend({ inlineEditor: this });

    var link = $("<a></a>").appendTo(element);
    link.click(function(){ observable.edit(); });
    ko.applyBindingsToNode(link[0], {
        text: observable,
        hidden: observable.isEditing
    });

    var input = $('<input type="text" />').appendTo(element);
    ko.applyBindingsToNode(input[0], {
      value: observable,
      visible: observable.isEditing,
      hasFocus: observable.isEditing
    });
    input.keyup(function(e) {
      var code = e.keyCode || e.which;
      if (code == 13) { // Enter
        observable.finishEditing();
      } else if (code == 27) { // Escape
        observable.abortEditing();
      }
    });
  }
};

ko.bindingHandlers.editorClass = {
  init: function(element, valueAccessor) {
    ko.applyBindingsToNode($('select,input', element)[0], {
      css: valueAccessor()
    });
  }
};

/*
 * Inline list editor
 */
ko.bindingHandlers.inlineListEditor = {
  init: function(element, valueAccessor, allBindings) {
    var observable = valueAccessor();
    observable.extend({ inlineEditor: this});

    var link = $("<a></a>").appendTo(element);
    link.click(function(){ observable.edit(); });
    ko.applyBindingsToNode(link[0], {
        text: observable,
        hidden: observable.isEditing
    });

    var select = $('<select></select>').appendTo(element);
    ko.applyBindingsToNode(select[0], {
      value: observable,
      visible: observable.isEditing,
      hasFocus: observable.isEditing,
    });
    select.keyup(function(e) {
      var code = e.keyCode || e.which;
      if (code == 13) { // Enter
        observable.finishEditing();
      } else if (code == 27) { // Escape
        observable.abortEditing();
      }
    });
  }
};

ko.bindingHandlers.listOptions = {
  init: function(element, valueAccessor, allBindings) {

    console.log("start listOptions applyBindingsToNode");

    ko.applyBindingsToNode($('select', element)[0], {
      options: valueAccessor(),
      optionsText: allBindings.get('listOptionsText'),
      optionsValue: allBindings.get('listOptionsValue'),
      multiple: allBindings.get('listMultiple')
    });

    console.log("end listOptions applyBindingsToNode");

  }
};
