class AccountsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_entity, only: [:index, :new, :create]
  before_filter :load_account, only: [:show, :edit, :update, :destroy]
  before_filter :set_current_entity
  respond_to :html, :json
  
  def destroy
    authorize! :destroy, @account
    @account.destroy
    flash[:notice] = "The account was successfully deleted."
    respond_with @account.entity, @account
  end
  
  def index
    authorize! :show, @entity
    @accounts = @entity.accounts
    respond_with @accounts
  end

  def show
    authorize! :show, @account
    respond_with @account
  end

  def new
    authorize! :update, @entity
    @account = @entity.accounts.new
  end

  def create
    authorize! :update, @entity
    @account = @entity.accounts.new(account_params)
    flash[:notice] = "The account was successfully created." if @account.save
    respond_with @account
  end

  def edit
    authorize! :update, @account
  end

  def update
    authorize! :update, @account
    @account.update_attributes(account_params)
    flash[:notice] = "The account was successfully updated." if @account.save
    respond_with @account
  end
  
  private
    def load_account
      parent = @entity.nil? ? Account : @entity.accounts
      @account = parent.find(params[:id])
    end
    
    def load_entity
      @entity = current_user.entities.find(params[:entity_id])
    end
    
    def set_current_entity
      self.current_entity = @entity || @account.entity
    end
    
    def account_params
      params.require(:account).permit(:name, :account_type, :entity_id, :parent_id)
    end
end
