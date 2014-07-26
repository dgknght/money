class LotsController < ApplicationController
  before_filter :authenticate_user!, :load_account
  respond_to :html, :json

  def index
    authorize! :show, @account
    @lots = @account.lots
    respond_with @lots
  end

  private

  def load_account
    @account = Account.find(params[:account_id])
  end
end
