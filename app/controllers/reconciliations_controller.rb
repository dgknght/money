class ReconciliationsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_account, only: [:new, :create]
  respond_to :html, :json
  
  def new
  end

  def create
  end
  
  private
    def load_account
      @account = Account.find(params[:account_id])
      authorize! :update, @account
      self.current_entity = @account.entity
    end
end
