class TransactionItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, only: [ :index ]
  
  respond_to :json, :html
  
  def index
    authorize! :show, @account.entity
    @balance = 0 # TODO Probably want to encapsulate this better
    @transaction_items = TransactionItem.where('account_id=?', @account.id)
  end
  
  private
    def load_account
      @account = Account.find(params[:account_id])
    end
end
