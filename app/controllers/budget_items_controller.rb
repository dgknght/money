class BudgetItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_budget, only: [:index, :create, :new]
  before_filter :load_budget_item, only: [:show, :update, :destroy, :edit]
  respond_to :html, :json
  
  def index
    authorize! :show, @budget
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
  end

  def create
    @budget_item = @budget.items.new(budget_item_params)
    authorize! :create, @budget_item
    flash[:notice] = "The budget item was created successfully." if @budget_item.save
    respond_with @budget_item
  end

  def edit
    authorize! :update, @budget_item
  end

  def update
    authorize! :update, @budget_item
    @budget_item.update_attributes(budget_item_params)
    flash[:notice] = "The budget item was updated successfully." if @budget_item.save
    respond_with @budget_item
  end

  def destroy
    authorize! :destroy, @budget_item
    @budget_item.destroy
    respond_with @budget_item.budget, @budget_item
  end
  
  private
    def budget_item_params
      params.require(:budget_item).permit(:account_id)
    end
    
    def load_budget
      @budget = Budget.find(params[:budget_id])
    end
    
    def load_budget_item
      @budget_item = BudgetItem.find(params[:id])
    end
end
