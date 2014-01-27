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
  end

  def show
  end

  def destroy
  end

  private
    def load_transaction
      @transaction = Transaction.find(params[:transaction_id])
    end
end
