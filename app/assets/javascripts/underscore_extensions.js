_.mixin({
  ensureDate: function(value) {
    if (typeof value == 'undefined' || value == null) {
      return null;
    }
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
  ensureNumber: function(value, defaultValue) {
    if (value == null) return defaultValue;
    if (typeof value === "number") return value;
    return parseFloat(value);
  },
  newString: function(character, length) {
    var result = "";
    for (var i = 0; i < length; i++) {
      result += character;
    }
    return result;
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
  findById: function(list, id) {
    return _.find(list, function(item) { return item.id == id })
  },
  uniqueInt: function() {
    return parseInt(_.uniqueId())
  }
});
