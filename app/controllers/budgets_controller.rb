class BudgetsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_budget, only: [:show, :edit, :update, :destroy]
  before_filter :load_entity, only: [:index, :new, :create, :udpate]
  before_filter :set_current_entity
  
  respond_to :html, :json
  
  def index
    authorize! :show, @entity
    @budgets = @entity.budgets
    respond_with @budgets
  end

  def new
    authorize! :update, @entity
    @budget = @entity.budgets.new
  end

  def create
    @budget = @entity.budgets.new(budget_params)
    flash[:notice] = "The budget was created successfully." if @budget.save
    respond_with @budget
  end

  def edit
    authorize! :update, @budget
  end

  def update
    authorize! :update, @budget
    @budget.update_attributes(budget_params)
    flash[:notice] = "The budget was updated successfully." if @budget.save
    respond_with @budget
  end

  def destroy
    authorize! :destroy, @budget
    @budget.destroy
    flash[:notice] = "The budget was removed successfully."
    respond_with @budget.entity, @budget
  end
  
  def show
    authorize! :show, @budget
    respond_with @budget
  end
  
  private
    def load_budget
      parent = @entity ? @entity.budgets : Budget
      @budget = parent.find(params[:id])
    end
    
    def load_entity
      if params[:entity_id]
        @entity = current_user.entities.find(params[:entity_id])
        set_current_entity
      else
        @entity = current_entity
      end
    end
    
    def budget_params
      params.require(:budget).permit(:name, :start_date, :period, :period_count)
    end
    
    def set_current_entity
      self.current_entity = @entity || @budget.entity
    end
end
