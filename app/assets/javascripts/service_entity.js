function ServiceEntity() {
}

ServiceEntity.prototype = {
  destroy: function() {
    if (!confirm("Are you sure you want to delete the acount \"" + this.entityDescription() + "\"?")) return;

    var self = this;
    $.ajax({
      url: this.entityPath(),
      type: 'DELETE',
      success: function(data, textStatus, jqXHR) {
        this.onDestroyed();
      },
      error: function(jqXHR, textStatus, errorThrown) {
        this.onServiceError(jqXHR, textStatus, errorThrown);
      },
      context: self
    });
  },
  entityDescription: function() {
    throw "You must override the entityDescription method.";
  },
  entityPath: function() {
    throw "You must override the entityPath method.";
  },
  onDestroyed: function() {
    console.log("The onDestroyed method was not overridden. This may have been a mistake.");
  },
  onServiceError: function(jqXHR, textStatus, errorThrown) {
    console.log("The onServiceError method was not overridden. " + errorThrown);
  }
};
