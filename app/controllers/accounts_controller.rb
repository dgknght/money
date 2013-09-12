class AccountsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html, :json
  
  def index
    @accounts = current_user.accounts
    respond_with @accounts
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end
end
