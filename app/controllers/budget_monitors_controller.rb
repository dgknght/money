class BudgetMonitorsController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :load_entity, only: [:index, :new, :create]
  before_filter :set_current_entity

  def index
    authorize! :show, @entity
    @budget_monitors, @nil_monitors = @entity.budget_monitors.partition{|m| !!m.period}
    @first = @budget_monitors.first
  end

  def new
    @budget_monitor = @entity.budget_monitors.new
  end

  def create
    @budget_monitor = @entity.budget_monitors.new(budget_monitor_params)
    flash[:notice] = 'The budget monitor was created successfully.' if @budget_monitor.save
    respond_with(@budget_monitor, location: entity_budget_monitors_path(@entity))
  end

  private

  def budget_monitor_params
    params.require(:budget_monitor).permit(:account_id)
  end

  def load_entity
    @entity = current_user.entities.find(params[:entity_id])
  end

  def set_current_entity
    self.current_entity = @entity || @transaction.entity
  end
end
