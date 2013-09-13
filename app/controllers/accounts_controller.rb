class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_account, :only => [:show, :edit, :update]
  
  respond_to :html, :json
  
  def index
    @accounts = current_user.accounts
    respond_with @accounts
  end

  def show
    respond_with @account
  end

  def new
    @account = current_user.accounts.new
  end

  def create
    @account = current_user.accounts.new(params[:account])
    flash[:notice] = "The account was successfully created." if @account.save
    respond_with @account
  end

  def edit
  end

  def update
    @account.update_attributes(params[:account])
    flash[:notice] = "The account was successfully updated." if @account.save
    respond_with @account
  end
  
  private
    def load_account
      @account = current_user.accounts.find(params[:id])
    end
end
