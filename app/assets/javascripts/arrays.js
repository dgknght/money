
/*
 * Array extension methods
 */
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

Array.prototype.pushAll = function(values) {
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