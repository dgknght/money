class LotsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, only: [:index]
  respond_to :html, :json

  def index
    authorize! :show, @account
    @lots = @account.lots
    respond_with @lots
  end

  def new_transfer
    @transfer = LotTransfer.new
    @account_id = params[:account_id]
  end


  def transfer
    @transfer = LotTransfer.new(transfer_params)
    if @transfer.execute
      flash[:notice] = 'The lot was transferred successfully.'
      redirect_to account_lots_path(params[:account_id])
    else
      render :new_transfer
    end
  end

  private

  def load_account
    @account = Account.find(params[:account_id])
  end
end
