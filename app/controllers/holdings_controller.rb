class HoldingsController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!, :load_account, :set_current_entity

  respond_to :html, :json

  def index
    authorize! :show, @account
    @holdings = @account.all_holdings
    @total_current_value = @holdings.reduce(0) { |sum, holding| sum += holding.current_value }
  end

  private

  def load_account
    @account = Account.find(params[:account_id])
  end

  def set_current_entity
    self.current_entity = @account.entity
  end
end
