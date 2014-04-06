class CommoditiesController < ApplicationController
  before_filter :load_entity, only: [:index, :create, :new]
  before_filter :load_commodity, only: [:show, :update, :destroy]
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
  end

  def create
    authorize! :update, @entity
    @commodity = @entity.commodities.new(commodity_params)
    flash[:notice] = "The commodity was created successfully." if @commodity.save
    respond_with(@commodity, location: entity_commodities_path(@entity))
  end

  def edit
  end

  def update
    @commodity.update_attributes(commodity_params)
    flash[:notice] = "The commodity was updated successful." if @commodity.save
    respond_with(@commodity, location: entity_commodities_path(@commodity.entity))
  end

  def destroy
    flash[:notice] = "The commodity was deleted successfully." if @commodity.destroy
    respond_with(@commodity, location: entity_commodities_path(@commodity.entity))
  end

  private
    def commodity_params
      params.require(:commodity).permit([:name, :symbol, :market])
    end

    def load_commodity
      @commodity = Commodity.find(params[:id])
    end

    def load_entity
      @entity = Entity.find(params[:entity_id])
    end
end
