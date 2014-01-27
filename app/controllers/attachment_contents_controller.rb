class AttachmentContentsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html

  def show
    content = AttachmentContent.find(params[:id])
    authorize! :show, content.attachment
    response.headers['Content-Type'] = content.attachment.content_type
    render text: content.data
  end
end
