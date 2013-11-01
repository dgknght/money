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
    @report = BudgetReport.new(@entity, @filter)
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
    def load_entity
      @entity = Entity.find(params[:id])
      self.current_entity = @entity
      redirect_to entities_path unless @entity
      authorize! :show, @entity
    end
end
