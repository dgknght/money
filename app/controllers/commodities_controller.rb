class CommoditiesController < ApplicationController
  before_filter :load_entity, only: [:index, :create]
  before_filter :load_commodity, only: [:show, :update]
  respond_to :html, :json

  def index
    @commodities = @entity.commodities
    respond_with(@commodities)
  end

  def show
    respond_with(@commodity)
  end

  def new
  end

  def create
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
