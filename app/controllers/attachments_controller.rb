class AttachmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_transaction, only: [:index, :new, :create]
  before_filter :load_attachment, only: [:show, :destroy]

  respond_to :html, :json

  def index
    authorize! :show, @transaction
    @attachments = @transaction.attachments
    respond_with @attachments
  end

  def new
    authorize! :update, @transaction
    @attachment = @transaction.attachments.new
  end

  def create
    authorize! :update, @transaction
    @attachment = @transaction.attachments.new(attachment_params)
    flash[:notice] = "The attachment was saved successfully." if @attachment.save
    respond_with @attachment, location: transaction_attachments_path(@transaction)
  end

  def show
    authorize! :show, @attachment
    respond_with @attachment
  end

  def destroy
    authorize! :destroy, @attachment
    @attachment.destroy
    flash[:notice] = "The attachment was removed successfully."
    respond_with @attachment, location: transaction_attachments_path(@attachment.transaction)
  end

  private
    def attachment_params
      return params.require(:attachment).permit([:raw_file, :name])
    end

    def load_attachment
      @attachment = Attachment.find(params[:id])
    end

    def load_transaction
      @transaction = Transaction.find(params[:transaction_id])
    end
end
