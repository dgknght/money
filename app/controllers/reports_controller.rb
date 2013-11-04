class ReportsController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!, :load_entity
  respond_to :html
  
  def balance_sheet
    @filter = BalanceSheetFilter.new(params)
    @report = BalanceSheetReport.new(@entity, @filter)
  end

  def budget
    @filter = BudgetFilter.new(params)
    @filter.budget_id ||= active_budget_id
    if @filter.valid?
      budget = @entity.budgets.find(@filter.budget_id)
      @report = BudgetReport.new(budget, @filter)
    end
  end

  def income_statement
    @filter = IncomeStatementFilter.new(params)
    @report = IncomeStatementReport.new(@entity, @filter)
  end
  
  def index    
    @reports = {
      'Balance Sheet' => balance_sheet_entity_path(@entity),
      'Income Statement' => income_statement_entity_path(@entity),
      'Budget' => budget_entity_path(@entity)
    }
  end
  
  private
    def active_budget_id
      budget = @entity.budgets.select{ |b| b.start_date <= Date.today && b.end_date >= Date.today}.first
      budget.nil? ? nil : budget.id
    end
    
    def load_entity
      @entity = Entity.find(params[:id])
      self.current_entity = @entity
      redirect_to entities_path unless @entity
      authorize! :show, @entity
    end
end
