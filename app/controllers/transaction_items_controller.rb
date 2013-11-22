class TransactionItemsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_account, only: [ :index, :create ]
  before_filter :load_transaction_item, only: [ :destroy ]
  respond_to :json, :html
  
  def create
    authorize! :update, @account.entity
    @transaction_item_creator = TransactionItemCreator.new(@account, creator_params)
    transaction_item = @transaction_item_creator.create
    if transaction_item
      flash[:notice] = "The transaction was created successfully."
      respond_with(transaction_item.transaction) do |format|
        format.html { redirect_to account_transaction_items_path(@account) }
      end
    else
      # TODO Remove this duplication
      @balance = 0 # TODO Probably want to encapsulate this better
      @transaction_items = @account.transaction_items
      render :index
    end
  end
  
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
    @transaction_items = @account.transaction_items.joins(:transaction).order('transactions.transaction_date')
    @transaction_item_creator = TransactionItemCreator.new(@account, transaction_date: Date.today)
    respond_with @transaction_items
  end
  
  private
    def creator_params
      params.require(:transaction_item_creator).permit(:other_account_id, :description, :transaction_date, :amount)
    end
    
    def load_account
      @account = Account.find(params[:account_id])
      self.current_entity = @account.entity
    end
    
    def load_transaction_item
      @transaction_item = TransactionItem.find(params[:id])
    end
end
