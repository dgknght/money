class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, except: :show
  before_filter :load_transaction, only: [:update, :show]
  
  respond_to :html, :json

  def index
    @transactions = TransactionPresenter.new(user: current_user, account: @account)
    @transaction = current_user.transactions.new(transaction_date: Date.today)
    @items = [
      @transaction.items.new(action: :credit, account: @account),
      @transaction.items.new(action: :debit)
    ]
    respond_with @transactions
  end

  def create
    @transaction = current_user.transactions.new(params[:transaction])
    flash[:notice] = "The transaction was created successfully." if @transaction.save
    respond_with(@transaction) do |format|
      format.html { redirect_to account_transactions_path(@account) }
    end
  end

  def update
    @transaction.update_attributes(params[:transaction])
    flash[:notice] = "The transaction was updated successfully." if @transaction.save
    respond_with(@transaction) do |format|
      format.html { redirect_to account_transactions_path(@account) }
    end
  end

  def show
    respond_with @transaction
  end
  
  private
  
    def load_account
      @account = current_user.accounts.find(params[:account_id])
    end
    
    def load_transaction
      @transaction = current_user.transactions.find(params[:id])
    end
end
