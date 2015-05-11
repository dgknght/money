class LotsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, only: [:index]
  before_filter :load_lot, only: [:transfer, :new_transfer, :exchange, :new_exchange]
  respond_to :html, :json

  def index
    authorize! :show, @account

    @lots = @account.lots
    respond_with @lots
  end

  def new_exchange
    authorize! :update, @lot
    @exchanger = CommodityExchanger.new
  end

  def exchange
    authorize! :update, @lot

    @exchanger = CommodityExchanger.new(exchange_attributes)
    if @exchanger.exchange
      flash[:notice] = 'The lot was exchanged successfully.'
      redirect_to account_lots_path(@lot.account.parent_id)
    else
      render :new_exchange
    end
  end

  def new_transfer
    authorize! :update, @lot

    @transfer = LotTransfer.new(lot: @lot)
    @account_id = params[:account_id].to_i
  end

  def transfer
    authorize! :update, @lot

    previous_account_id = @lot.account_id
    @transfer = LotTransfer.new(transfer_params)
    if @transfer.transfer
      flash[:notice] = 'The lot was transferred successfully.'
      redirect_to account_lots_path(previous_account_id)
    else
      render :new_transfer
    end
  end

  private

  def exchange_attributes
    params.require(:exchange).permit(:commodity_id).merge(lot: @lot)
  end

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
