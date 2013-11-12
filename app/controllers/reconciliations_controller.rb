class ReconciliationsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_account, only: [:new, :create]
  respond_to :html, :json
  
  def new
    @reconciliation = @account.reconciliations.new
    @reconciliation.reconciliation_date = @reconciliation.default_reconciliation_date
  end

  def create
    @reconciliation = @account.reconciliations.new(reconciliation_params)
    flash[:notice] = "The account was reconciled successfully." if @reconciliation.save
    respond_with @reconciliation
  end
  
  private
    def load_account
      @account = Account.find(params[:account_id])
      authorize! :update, @account
      self.current_entity = @account.entity
    end
    
    def reconciliation_params
      params.require(:reconciliation).permit(:account_id, :reconciliation_date, :closing_balance, :items_attributes => [:transaction_item_id])
    end
end
