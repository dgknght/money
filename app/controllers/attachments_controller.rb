class AttachmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_transaction, only: [:index, :new, :create]

  respond_to :html, :json

  def index
    authorize! :show, @transaction
    @attachments = []
    respond_with @attachments
  end

  def new
    authorize! :update, @transaction
  end

  def create
    @attachment = @transaction.attachments.new(attachment_params)
    flash[:notice] = "The attachment was saved successfully." if @attachment.save

    puts "@attachment.valid?=#{@attachment.valid?}"
    @attachment.errors.full_messages.each { |m| puts m }

    respond_with(@attachment) do |format|
      if @attachment.valid?
        format.html { redirect_to transaction_attachments_path(@transaction) }
      else
        format.html { render :new }
      end
    end
  end

  def show
  end

  def destroy
  end

  private
    def attachment_params
      return params.require(:attachment).permit(:raw_file)
    end

    def load_transaction
      @transaction = Transaction.find(params[:transaction_id])
    end
end
