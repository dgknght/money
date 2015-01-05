class BudgetMonitorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_entity, only: [:index, :new]

  def index
    authorize! :show, @entity
  end

  def new
    @budget_monitor = @entity.budget_monitors.new
  end

  private

  def load_entity
    @entity = current_user.entities.find(params[:entity_id])
  end
end
