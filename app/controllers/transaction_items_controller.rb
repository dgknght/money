class TransactionItemsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_account, only: [ :index, :create, :new ]
  before_filter :load_transaction_item, only: [ :destroy, :update, :edit ]
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
    destroyer = TransactionDestroyer.new(@transaction_item.transaction)
    if destroyer.destroy
      flash[:notice] = destroyer.notice
    else
      flash[:error] = destroyer.error
    end
    respond_with @transaction, location: account_transaction_items_path(@transaction_item.account)
  end
  
  def edit
    authorize! :edit, @transaction_item
    @transaction_item_creator = TransactionItemCreator.new(@transaction_item)
  end
  
  def index
    authorize! :show, @account
    # TODO Add pagination here
    @transaction_items = @account.transaction_items.order('transaction_items."index" desc').take(10).to_a
    respond_with @transaction_items
  end
  
  def new
    authorize! :edit, @account
    @transaction_item_creator = TransactionItemCreator.new(@account)
  end
  
  def update
    authorize! :update, @transaction_item
    @transaction_item_creator = TransactionItemCreator.new(@transaction_item, creator_params)
    flash[:notice] = "The transaction was updated successfully." if @transaction_item_creator.update
    respond_with(@transaction_item) do |format|
      format.html { redirect_to account_transaction_items_path(@transaction_item.account) }
    end
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
      @account = @transaction_item.account
    end
end
