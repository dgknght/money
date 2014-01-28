function AttachmentViewModel(attachment, transaction) {
  this.transaction = transaction;
  this.id = ko.observable(attachment.id);
  this.name = ko.observable(attachment.name);
  this.content_type = ko.observable(attachment.content_type);
}
AttachmentViewModel.prototype = new ServiceEntity();
