/*
 * Array extension methods
 */
Array.prototype.any = function(predicate) {
  for (var i = 0; i < this.length; i++) {
    if (predicate(this[i]))
      return true;
  }
  return false;
};

Array.prototype.delimit = function(delimitor) {
  var result = "";
  var first = true;
  delimitor = delimitor || ",";
  $.each(this, function(index, value) {
    if (first)
      first = false;
    else
      result += delimitor;
    result += value
  });
  return result;
};

Array.prototype.first = function(predicate) {
  if (predicate == null)
    predicate = function() { return true; };

  for (var i = 0; i < this.length; i++) {
    var item = this[i];
    if (predicate(item))
      return item;
  }
  return null;
};

Array.prototype.groupBy = function(getKey) {
  var result = new Object();
  for (var i = 0; i < this.length; i++) {
    var value = this[i];
    var key = getKey(value);
    
    var list = result[key];
    if (list == null) {
      list = new Array();
      result[key] = list;
    }
    list.push(value);
  }
  return result;
};

Array.prototype.firstIndexOf = function(predicate) {
  for (var i = 0; i < this.length; i++) {
    if (predicate(this[i]))
      return i;
  }
  return -1;
};

Array.prototype.flatten = function() {
  var result = new Array();
  $.each(this, function(index, item) {
    if (item instanceof Array) {
      $.each(item, function(i, v) {
        result.push(v);
      });
    } else {
      result.push(item);
    }
  });
  return result;
};

Array.prototype.map = function(transform) {
  return $.map(this, transform);
}

Array.prototype.pushAll = function(values) {
  if (values == null) return;
  $.each(values, function(index, value) { this.push(value); });
};

Array.prototype.pushAllTo = function(target) {
  if (target.push === 'undefined')
    throw "The target \"" + target + "\" must be an array.";
  $.each(this, function(index, value){ target.push(value); });
};

Array.prototype.sum = function(getValue) {
  var result = 0;
  $.each(this, function(index, value) { result += getValue(value); });
  return result;
};

Array.prototype.where = function(predicate) {
  var result = new Array();
  for (var i = 0; i < this.length; i++) {
    var value = this[i];
    if (predicate(value))
      result.push(value)
  }
  return result;
};
