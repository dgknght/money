function AttachmentViewModel(attachment, transaction) {
  var _self = this;
  this.transaction = transaction;
  this.id = ko.observable();
  this.name = ko.observable();
  this.content_type = ko.observable();
  this.attachment_content_id = ko.observable();
  this.raw_file = ko.observable();

  if (attachment) {
    this.id(attachment.id);
    this.name(attachment.name);
    this.content_type(attachment.content_type);
    this.attachment_content_id(attachment.attachment_content_id);
  }

  this.save = function(success) {
    success = _.ensureFunction(success);
    var data = new FormData();
    data.append("attachment[raw_file]", this.raw_file());
    data.append("attachment[name]", this.name());
    $.ajax( {
      url: this.entityListPath(),
      data: data,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: function(data) {
        _self.id(data.id);
        _self.name(data.name);
        _self.content_type(data.content_type);
        _self.attachment_content_id(data.attachment_content_id);
        _self.transaction.attachments.push(_self);
        success();
      }
    });
  }

  this.show = function() {
    var url = "attachment_contents/{id}".format({ id: this.attachment_content_id() });
    window.open(url, "_blank");
  }

  this.entityIdentifier = function() {
    return "attachment";
  };
  this.entityListPath = function() {
    return "transactions/{transaction_id}/attachments.json".format({transaction_id: this.transaction.id()});
  };
}
