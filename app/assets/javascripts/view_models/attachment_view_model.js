function AttachmentViewModel(attachment, transaction) {
  this.transaction = transaction;
  if (attachment) {
    this.id = ko.observable(attachment.id);
    this.name = ko.observable(attachment.name);
    this.content_type = ko.observable(attachment.content_type);
    this.attachment_content_id = ko.observable(attachment.attachment_content_id);
  }

  this.show = function() {
    var url = "attachment_contents/{id}".format({ id: this.attachment_content_id() });
    window.open(url, "_blank");
  }
}
AttachmentViewModel.prototype = new ServiceEntity();
