class CommoditiesController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :load_entity, only: [:index, :create, :new]
  before_filter :load_commodity, only: [:show, :update, :destroy, :edit, :new_split, :split]
  before_filter :set_current_entity, only: [:show, :update, :edit, :destroy]
  respond_to :html, :json

  def index
    authorize! :show, @entity
    @commodities = @entity.commodities
    respond_with(@commodities)
  end

  def show
    authorize! :show, @commodity
    respond_with(@commodity)
  end

  def new
    authorize! :update, @entity
    @commodity = @entity.commodities.new
  end

  def new_split
    @split = CommoditySplitter.new(commodity: @commodity)
    @account_id = params[:account_id]
  end

  def split
    @split = CommoditySplitter.new(split_params)
    if @split.split # returns the list of lots affected
      redirect_to account_lots_path(params[:account_id])
    else
      render :new_split
    end
  end

  def create
    authorize! :update, @entity
    @commodity = @entity.commodities.new(commodity_params)
    flash[:notice] = "The commodity was created successfully." if @commodity.save
    respond_with(@commodity, location: entity_commodities_path(@entity))
  end

  def edit
    authorize! :update, @commodity
  end

  def update
    authorize! :update, @commodity
    @commodity.update_attributes(commodity_params)
    flash[:notice] = "The commodity was updated successfully." if @commodity.save
    respond_with(@commodity, location: entity_commodities_path(@commodity.entity))
  end

  def destroy
    authorize! :destroy, @commodity
    flash[:notice] = "The commodity was removed successfully." if @commodity.destroy
    respond_with(@commodity, location: entity_commodities_path(@commodity.entity))
  end

  private
    def commodity_params
      params.require(:commodity).permit([:name, :symbol, :market])
    end

    def split_params
      params.require(:split).permit([:numerator, :denominator]).merge(commodity: @commodity)
    end

    def load_commodity
      @commodity = Commodity.find(params[:id])
    end

    def load_entity
      if params[:entity_id]
        @entity = current_user.entities.find(params[:entity_id])
        set_current_entity
      else
        @entity = current_entity
      end
    end

    def set_current_entity
      self.current_entity = @entity || @commodity.entity
    end
end
