class TransactionsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_account, only: [ :index, :create ]
  before_filter :load_entity, only: [ :index, :create]
  before_filter :load_transaction, only: [:update, :show, :destroy]
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
    @transactions = TransactionPresenter.new(entity: @entity, account: @account)
    @transaction = @entity.transactions.new(transaction_date: Date.today)
    @items = [
      @transaction.items.new(action: :credit),
      @transaction.items.new(action: :debit)
    ]
    respond_with @transactions
  end

  def create
    authorize! :update, @entity
    @transaction = @entity.transactions.new(transaction_params)
    flash[:notice] = "The transaction was created successfully." if @transaction.valid? && TransactionManager.new(@transaction).create
    respond_with @transaction, location: create_redirect_path
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
      params.require(:transaction).permit(:transaction_date,
                                          :description,
                                          :items_attributes => [ :id,
                                                                 :_destroy,
                                                                 :account_id,
                                                                 :amount,
                                                                 :memo,
                                                                 :confirmation,
                                                                 :action ])
    end
end
