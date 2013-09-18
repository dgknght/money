class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html, :json

  def index
    @transactions = current_user.transactions
    respond_with @transactions
  end

  def create
    @transaction = current_user.transactions.new(params[:transaction])
    flash[:notice] = "The transaction was created successfully,." if @transaction.save
    respond_with @transaction do |format|
      format.html { redirect_to account_transactions_path(account) }
    end
  end

  def update
  end

  def show
  end
  
  private
  
    def account
      @account ||= current_user.accounts.find(params[:account_id])
    end
end
