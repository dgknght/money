class TransactionItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, only: [ :index ]
  before_filter :load_transaction_item, only: [ :destroy ]
  respond_to :json, :html
  
  def destroy
    authorize! :destroy, @transaction_item
    begin
      flash[:notice] = "The transaction was deleted successfully." if @transaction_item.transaction.destroy
      respond_with @transaction_item do |format|
        format.html { redirect_to account_transaction_items_path(@transaction_item.account) }
      end
    rescue Money::CannotDeleteError => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
  
  def index
    authorize! :show, @account
    @balance = 0 # TODO Probably want to encapsulate this better
    @transaction_items = @account.transaction_items
    respond_with @transaction_items
  end
  
  private
    def load_account
      @account = Account.find(params[:account_id])
    end
    
    def load_transaction_item
      @transaction_item = TransactionItem.find(params[:id])
    end
end
