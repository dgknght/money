class AccountsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html, :json
  
  def index
    @accounts = current_user.accounts
    respond_with @accounts
  end

  def show
    @account = current_user.accounts.find(params[:id])
    respond_with @account
  end

  def new
    @account = current_user.accounts.new
    respond_with @account
  end

  def create
    @account = current_user.accounts.new(params[:account])
    flash[:notice] = "The account was successfully created." if @account.save
    respond_with @account
  end

  def edit
  end

  def update
  end
end
