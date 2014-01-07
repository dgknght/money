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
    var observable = valueAccessor();
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

    if (allBindings.has('autocompleteLookup')) {
      input.autocomplete({ 
        source: allBindings.get('autocompleteLookup'),
        select: function(event, ui) {
          observable(ui.item.value);
        }
      });
    }

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

ko.bindingHandlers.inlineDateEditor = {
  init: function(element, valueAccessor, allBindings) {
    var observable = valueAccessor();
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

    input.datepicker();

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
 * autocomplete
 *
 * Uses jQueryUI autocomplete to creating a text box binding
 */
ko.bindingHandlers.autocomplete = {
  init: function(element, valueAccessor, allBindings) {
    var observable = valueAccessor();

    if (!allBindings.has('source'))
      throw "The source binding must be specified";
    $(element).autocomplete({
      source: allBindings.get('source'),
      select: function(event, ui) {
        observable(ui.item.value);
      }
    });

    ko.applyBindingsToNode(element, {
      value: observable
    });
  }
};

/*
 * datePicker
 *
 * Uses jQueryUI datepicker to create a text box binding
 */
ko.bindingHandlers.datePicker = {
  init: function(element, valueAccessor, allBindings) {
    $(element).datepicker();

    var observable = valueAccessor();
    ko.applyBindingsToNode(element, {
      value: observable
    });
  }
};

/*
 * errable
 *
 * Extension that adds properties for managing validation and other errors
 */
ko.extenders.errable = function(target) {
  target.errorMessage = ko.observable();
  target.hasError = ko.computed(function() {
    return target.errorMessage() != null;
  }, this);
};

/*
 * required
 *
 * Extension that invalidates a property that is required but empty
 */
ko.extenders.required = function(target, message) {
  target.extend({ errable: this});

  function validate(value) {
    target.errorMessage(value ? null : message || "This field is required.");
  }

  validate(target());

  target.subscribe(validate);

  return target;
};
