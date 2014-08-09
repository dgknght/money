_.mixin({
  ensureDate: function(value) {
    if (_.isDate(value)) {
      return value;
    }
    if (_.isString(value)) {
      return _.parseDate(value);
    }
    throw "The value \"" + value + "\" is not a valid date.";
  },
  ensureFunction: function(f) {
    if (f != null && typeof f === "function")
      return f;
    return function() {};
  },
  newString: function(character, length) {
    var result = "";
    for (var i = 0; i < length; i++) {
      result += character;
    }
    return result;
  },
  padLeft: function(value, totalLength, character) {
    var currentLength = value == null ? 0 : value.length;
    var padLength = totalLength - currentLength;
    if (padLength > 0)
      return _.newString(character || " ", padLength) + value;
    return value;
  },
  parseDate: function(value) {
    var match = (/(\d{4})-(\d{2})-(\d{2})/).exec(value);
    if (match) {
      var year = match[1];
      var month = match[2];
      var day = match[3];
      return new Date(year, month-1, day);
    }
    return new Date(value);
  },
  sortedIndexDesc: function(list, value, iterator, context) {
    var reversedCopy = _.toArray(list).reverse();
    var reversedIndex = _.sortedIndex(reversedCopy, value, iterator, context);
    return list.length - reversedIndex;
  },
  toIsoDate: function(date) {
    return date.getFullYear()
      + "-" + _.padLeft((date.getMonth() + 1) + "", 2, "0")
      + "-" + _.padLeft(date.getDate() + "", 2, "0")
  },
  findByMethod: function(list, methodName, value) {
    return _.find(list, function(item) {
      return item[methodName]() == value;
    });
  },
  findById: function(list, id) {
    return _.findByMethod(list, 'id', id);
  },
  getFromLazyLoadedArray: function(array, id, callback) {
    if (array.state() == 'loaded') {
      var result = _.findById(array(), id);
      callback(result);
      return;
    }

    var subscription = null;
    var timeoutId = window.setTimeout(function() {
      if (subscription != null) subscription.dispose();
      callback(null);
    }, 2000);

    subscription = array.subscribe(function(values) {
      var result = _.findById(values, id);
      if (result != null) {
        window.clearTimeout(timeoutId);
        subscription.dispose();
        callback(result);
      }
    });
    array();
  }
});
