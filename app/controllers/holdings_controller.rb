class HoldingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account

  respond_to :html, :json

  def index
    authorize! :show, @account
    @holdings = @account.holdings
  end

  private

  def load_account
    @account = Account.find(params[:account_id])
  end
end
