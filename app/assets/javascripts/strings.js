/*
 * String extension methods
 */
String.prototype.format = function(args) {
  return this.replace(/{([^{}]*)}/g, function (fullMatch, subMatch) {
    var value = args[subMatch];
    return (typeof value === 'string' || typeof value === 'number') ? value : fullMatch;
  });
};

String.prototype.compareTo = function(otherString) {
  if (this < otherString) return -1;
  if (this > otherString) return 1;
  return 0;
};

String.prototype.parseMoney = function() {
  var scrubbed = this.replace(/[^0-9\.]/g, "");
  return parseFloat(scrubbed);
};
