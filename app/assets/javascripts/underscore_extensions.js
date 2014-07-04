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
  toIsoDate: function(date) {
    return date.getFullYear()
      + "-" + _.padLeft((date.getMonth() + 1) + "", 2, "0")
      + "-" + _.padLeft(date.getDate() + "", 2, "0")
  },
  padLeft: function(value, totalLength, character) {
    var currentLength = value == null ? 0 : value.length;
    var padLength = totalLength - currentLength;
    if (padLength > 0)
      return _.newString(character || " ", padLength) + value;
    return value;
  },
  newString: function(character, length) {
    var result = "";
    for (var i = 0; i < length; i++) {
      result += character;
    }
    return result;
  }
});
