class BudgetsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  before_filter :load_entity, only: [:index, :new, :create]
  before_filter :load_budget, only: [:show]
  before_filter :set_current_entity
  
  respond_to :html, :json
  
  def index
    @budgets = @entity.budgets
    respond_with @budgets
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end
  
  def show
    respond_with @budget
  end
  
  private
    def load_budget
      parent = @entity ? @entity.budgets : Budget
      @budget = parent.find(params[:id])
    end
    
    def load_entity
      @entity = current_user.entities.find(params[:entity_id])
    end
    
    def set_current_entity
      self.current_entity = @entity || @budget.entity
    end
end
