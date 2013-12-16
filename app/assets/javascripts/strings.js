/*
 * String extension methods
 */
String.prototype.format = function(args) {
  return this.replace(/{([^{}]*)}/g, function (fullMatch, subMatch) {
    var value = args[subMatch];
    return (typeof value === 'string' || typeof value === 'number') ? value : fullMatch;
  });
};
