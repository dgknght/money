class TransactionsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_account, only: [ :index, :create ]
  before_filter :load_entity, only: [ :index, :create, :new ]
  before_filter :load_transaction, only: [:update, :show, :destroy, :edit]
  before_filter :set_current_entity
  
  respond_to :html, :json

  def destroy
    authorize! :destroy, @transaction
    destroyer = TransactionDestroyer.new(@transaction)
    if destroyer.destroy
      flash[:notice] = destroyer.notice
    else
      flash[:error] = destroyer.error
    end
    respond_with @transaction.entity, @transaction
  end
  
  def index
    authorize! :show, @entity
    # TODO Add pagination here
    @transactions = TransactionPresenter.new(entity: @entity, account: @account).take(10)
    respond_with @transactions
  end

  def new
    authorize! :update, @entity
    @transaction = @entity.transactions.new
    @items = Array.new(10)
  end

  def create
    authorize! :update, @entity
    @transaction = @entity.transactions.new(transaction_params)
    if @transaction.valid? && TransactionManager.new(@transaction).create
      flash[:notice] = "The transaction was created successfully."
    else
      @items = wrap_in_array(@transaction.items)
    end
    respond_with @transaction, location: create_redirect_path
  end

  def edit
    authorize! :update, @transaction
    @items = wrap_in_array(@transaction.items)
  end

  def update
    authorize! :update, @transaction
    @transaction.attributes = transaction_params
    flash[:notice] = "The transaction was updated successfully." if @transaction.valid? && TransactionManager.new(@transaction).update
    respond_with @transaction, location: entity_transactions_path(@transaction.entity)
  end

  def show
    authorize! :show, @transaction
    respond_with @transaction
  end
  
  private
    def create_redirect_path
      return account_transactions_path(@account) if @account
      entity_transactions_path(@entity)
    end
    
    def load_account
      @account = Account.find(params[:account_id]) if params[:account_id]
    end
    
    def load_entity
      if @account
        @entity = @account.entity
      else
        @entity = Entity.find(params[:entity_id])
      end
    end
    
    def load_transaction
      @transaction = Transaction.find(params[:id])
    end
    
    def set_current_entity
      self.current_entity = @entity || @transaction.entity
    end
    
    def transaction_params
      result = params.require(:transaction).permit(:transaction_date,
                                          :description,
                                          :items_attributes => [ :id,
                                                                 :_destroy,
                                                                 :account_id,
                                                                 :amount,
                                                                 :memo,
                                                                 :confirmation,
                                                                 :action ])
      result[:transaction_date] = Chronic.parse(result[:transaction_date])
      if result[:items_attributes]
        result[:items_attributes] = result[:items_attributes].reject{|i| i[:account_id].blank?}
      end
      result
    end

    def wrap_in_array(items)
      result = Array.new(10)
      items.each_with_index do |item, index|
        result[index] = item
      end
      result
    end
end
