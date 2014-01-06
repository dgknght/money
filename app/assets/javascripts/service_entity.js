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
  entityIdentifier: function() {
    throw "You must override the entityIdentifier method.";
  },
  entityListPath: function() {
    throw "You must override the entityListPath method.";
  },
  entityPath: function() {
    throw "You must override the entityPath method.";
  },
  getPostData: function() {
    var result = new Object();
    result[this.entityIdentifier()] = this.toJson();
    return result;
  },
  insert: function(success, error, complete) {
    var path = this.entityListPath();
    var self = this;
    $.ajax({
      url: path,
      accepts: 'json',
      type: 'POST',
      dataType: 'json',
      data: this.getPostData(),
      success: function(data) {
        self.id = data.id;
        self.insertSucceeded();
        success();
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log("*** ERROR ***");
        console.log("textStatus=" + textStatus);
        console.log("errorThrown=" + errorThrown);
        console.log("jqXHR.responseText=" + jqXHR.responseText);

        errorObj = $.parseJSON(jqXHR.responseText);
        self.insertFailed(errorObj);
        error(errorObj);
      },
      complete: function(jqXHR, textStatus) {
        self.insertCompleted();
        complete();
      }
    });
  },
  insertCompleted: function() {},
  insertFailed: function() {},
  insertSucceeded: function() {},
  onDestroyed: function() {
    console.log("The onDestroyed method was not overridden. This may have been a mistake.");
  },
  onServiceError: function(jqXHR, textStatus, errorThrown) {
    console.log("The onServiceError method was not overridden. " + errorThrown);
  },
  save: function(success, error, complete) {
    success = success == null ? function() {} : success;
    error = error == null ? function() {} : error;
    complete = complete == null ? function() {} : complete;
    if (this.id == null) {
      this.insert(success, error, complete);
    } else {
      this.update(success, error, complete);
    }
  },
  toJson: function() {
    throw "You must override the toJson method.";
  },
  update: function(success, error, complete) {
    var self = this;
    $.ajax({
      url: this.entityPath(),
      type: 'PUT',
      dataType: 'json',
      data: this.getPostData(),
      success: function() {
        self.updateSucceeded();
        success();
      },
      complete: function() {
        self.updateCompleted();
        complete();
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log("*** ERROR ***");
        console.log("textStatus=" + textStatus);
        console.log("errorThrown=" + errorThrown);
        console.log("jqXHR.responseText=" + jqXHR.responseText);

        errorObj = $.parseJSON(jqXHR.responseText);
        self.updateFailed(errorObj);
        error(errorObj);
      }
    });
  },
  updateCompleted: function() {},
  updateFailed: function() {},
  updateSucceeded: function() {}
};