class TransactionsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_entity, only: [ :index, :create ]
  before_filter :load_transaction, only: [:update, :show]
  before_filter :set_current_entity
  
  respond_to :html, :json

  def index
    authorize! :show, @entity
    @transactions = TransactionPresenter.new(entity: @entity)
    @transaction = @entity.transactions.new(transaction_date: Date.today)
    @items = [
      @transaction.items.new(action: :credit),
      @transaction.items.new(action: :debit)
    ]
    respond_with @transactions
  end

  def create
    authorize! :update, @entity
    @transaction = @entity.transactions.new(params[:transaction])
    flash[:notice] = "The transaction was created successfully." if @transaction.save
    respond_with(@transaction) do |format|
      format.html { redirect_to entity_transactions_path(@entity) }
    end
  end

  def update
    authorize! :update, @transaction
    @transaction.update_attributes(params[:transaction])
    flash[:notice] = "The transaction was updated successfully." if @transaction.save
    respond_with(@transaction) do |format|
      format.html { redirect_to entity_transactions_path(@transaction.entity) }
    end
  end

  def show
    authorize! :show, @transaction
    respond_with @transaction
  end
  
  private
    def load_entity
      @entity = Entity.find(params[:entity_id])
    end
    
    def load_transaction
      @transaction = Transaction.find(params[:id])
    end
    
    def set_current_entity
      self.current_entity = @entity || @transaction.entity
    end
end
