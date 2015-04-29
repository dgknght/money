class LotsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, only: [:index]
  before_filter :load_lot, only: [:transfer, :new_transfer]
  respond_to :html, :json

  def index
    authorize! :show, @account
    @lots = @account.lots
    respond_with @lots
  end

  def new_transfer
    authorize! :update, @lot

    @transfer = LotTransfer.new
    @account_id = params[:account_id]
  end


  def transfer
    authorize! :update, @lot

    @transfer = LotTransfer.new(transfer_params)
    if @transfer.transfer
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

  def load_lot
    @lot = Lot.find(params[:id])
  end

  def transfer_params
    params.require(:transfer).permit(:target_account_id).merge(lot: @lot)
  end
end
