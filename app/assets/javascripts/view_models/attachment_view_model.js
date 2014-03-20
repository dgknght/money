function AttachmentViewModel(attachment, transaction) {
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

  this.show = function() {
    var url = "attachment_contents/{id}".format({ id: this.attachment_content_id() });
    window.open(url, "_blank");
  }

  this.entityIdentifier = function() {
    return "attachment";
  };
  this.entityListPath = function() {
    return "transactions/{transaction_id}/attachments.json".format({transaction_id: _self.transaction.id()});
  };
  this.toJson = function() {
    return {
      id: _self.id(),
      name: _self.name(),
      content_type: _self.content_type(),
      attachment_content_id: _self.attachment_content_id()
    };
  };
}
AttachmentViewModel.prototype = new ServiceEntity();
