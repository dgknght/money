class AccountsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_entity, only: [:index, :new, :create, :new_import, :import]
  before_filter :load_account, except: [:index, :new, :create, :new_import, :import]
  before_filter :set_current_entity
  respond_to :html, :json
  
  def destroy
    authorize! :destroy, @account
    @account.destroy
    flash[:notice] = "The account was successfully deleted."
    respond_with @account.entity, @account
  end
  
  def import
    @importer = AccountImporter.new(import_params)
    flash[:notice] = 'The accounts were imported successfully.' if @importer.save
    respond_with @importer, location: entity_accounts_path(@entity)
  end

  def index
    authorize! :show, @entity
    @accounts = AccountsPresenter.new(@entity)
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

  def new_commodity_transaction
    authorize! :update, @account
    @creator = CommodityTransactionCreator.new account: @account
  end

  def new_import
    @importer = AccountImporter.new(import_params)
  end

  def create
    authorize! :update, @entity
    @account = @entity.accounts.new(account_params)
    flash[:notice] = "The account was successfully created." if @account.save
    respond_with @account, location: entity_accounts_path(@entity)
  end

  def create_commodity_transaction
    authorize! :update, @account
    @creator = CommodityTransactionCreator.new purchase_params

    flash[:notice] = "The transaction was created successfully." if @creator.create
    respond_with @creator, location: holdings_account_path(@account),
                            action: :new_commodity_transaction
  end

  def edit
    authorize! :update, @account
  end

  def holdings
    authorize! :show, @account
  end

  def update
    authorize! :update, @account
    @account.update_attributes(account_params)
    flash[:notice] = "The account was successfully updated." if @account.save
    respond_with @account, location: entity_accounts_path(@account.entity)
  end
  
  private
    def account_params
      params.require(:account).permit(:name, :account_type, :entity_id, :parent_id, :content_type)
    end

    def import_params
      params.require(:import).permit(:file)
    end

    def load_account
      parent = @entity.nil? ? Account : @entity.accounts
      @account = parent.find(params[:id])
    end
    
    def load_entity
      @entity = current_user.entities.find(params[:entity_id])
    end
    
    def purchase_params
      params.require(:purchase).permit(:transaction_date, :symbol, :action, :shares, :value).merge(account: @account)
    end

    def set_current_entity
      self.current_entity = @entity || @account.entity
    end
end
