class BudgetItemsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_budget, only: [:index, :create, :new]
  before_filter :load_budget_item, only: [:show, :update, :destroy, :edit]
  before_filter :set_current_entity
  
  respond_to :html, :json
  
  def index
    authorize! :show, @budget
    @budget_summary = BudgetSummary.new(@budget)
    @budget_items = @budget.items
    respond_with @budget_items
  end

  def show
    authorize! :show, @budget_item
    respond_with @budget_item
  end

  def new
    authorize! :update, @budget
    @budget_item = @budget.items.new
    @distributor = BudgetItemDistributor.new(@budget_item, params[:method])
  end

  def create
    @budget_item = @budget.items.new(budget_item_params)
    authorize! :create, @budget_item
    distribute
    flash[:notice] = "The budget item was created successfully." if @budget_item.save
    respond_with @budget_item, location: budget_budget_items_path(@budget)
  end

  def edit
    authorize! :update, @budget_item
    @distributor = BudgetItemDistributor.new(@budget_item, BudgetItemDistributor.average)
  end

  def update
    authorize! :update, @budget_item
    @budget_item.update_attributes(budget_item_params)
    distribute
    flash[:notice] = "The budget item was updated successfully." if @budget_item.save
    respond_with @budget_item, location: budget_budget_items_path(@budget_item.budget)
  end

  def destroy
    authorize! :destroy, @budget_item
    @budget_item.destroy
    respond_with @budget_item.budget, @budget_item
  end
  
  private
    def budget_item_params
      params.require(:budget_item).permit(:account_id, { periods_attributes: [:budget_amount, :start_date]})
    end
    
    def distribute
      params = distributor_params
      return unless params

      @distributor = BudgetItemDistributor.new(@budget_item)
      @distributor.apply_attributes(params)
      @distributor.distribute
    end
    
    def distributor_params
      return nil unless params[:distributor]
      params.require(:distributor).permit(:method).tap do |allowed|
        allowed[:options] = params[:distributor][:options]
      end
    end
    
    def load_budget
      @budget = Budget.find(params[:budget_id])
    end
    
    def load_budget_item
      @budget_item = BudgetItem.find(params[:id])
    end
    
    def set_current_entity
      self.current_entity = @budget ? @budget.entity : @budget_item.budget.entity
    end
end
