/*
 * String extension methods
 */
String.prototype.format = function(args) {
  return this.replace(/{([^{}]*)}/, function (fullMatch, subMatch) {
    var value = args[subMatch];
    return (typeof value === 'string' || typeof value === 'number') ? value : fullMatch;
  });
};

/*
 * Array extension methods
 */
Array.prototype.where = function(predicate) {
  var result = new Array();
  for (var i = 0; i < this.length; i++) {
    var value = this[i];
    if (predicate(value))
      result.push(value)
  }
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

/*
 * Constructor for the client-side application
 */
function MoneyApp() {
  var _self = this;
  this.selectedEntity.subscribe(function(entity) {
    _self.loadAccounts(entity);
  });
  $.getJSON("entities.json", function(entities) {
    _self.loadEntities(entities); 
  });
};

/*
 * Prototype for the client-side application
 */
MoneyApp.prototype = {
  entities: ko.observableArray(),
  selectedEntity: ko.observable(),
  accounts: ko.observableArray(),
  loadAccountList: function(allAccounts) {
    var grouped = allAccounts.groupBy(function(a) { return a.account_type; });
    
    var flattened = new Array();
    for(var key in grouped) {
      flattened.push({ name: key });
      var group = grouped[key];      
      for (var i = 0; i < group.length; i++) {
        flattened.push(group[i]);
      }
    }
    
    for (var i = 0; i < flattened.length; i++) {
      this.accounts.push(flattened[i]);
    }
  },
  loadAccounts: function (entity) {
    this.accounts.removeAll()
    if (entity == null) return;
    
    var path = "entities/{id}/accounts.json".format({ id: entity.id });
    var self = this;
    $.getJSON(path, function(accounts) {
      self.loadAccountList(accounts);
    });
  },
  loadEntities: function (entities) {
    for (var i = 0; i < entities.length; i++) {
      this.entities.push(entities[i]);
    }
  }
}