class PricesController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :load_price, only: [:show, :edit, :update, :destroy]
  before_filter :load_commodity, only: [:index, :new, :create, :edit]
  before_filter :set_current_entity
  respond_to :html, :json

  def download
    entity = Entity.find(params[:entity_id])
    authorize! :update, entity
    StockPrices::PriceDownloader.new(entity).download
    redirect_to entity_commodities_path(entity)
  end

  def index
    authorize! :show, @commodity
    @prices = @commodity.prices
    respond_with @prices
  end

  def show
    authorize! :show, @price
    respond_with(@price)
  end

  def new
    authorize! :update, @commodity
    @price = @commodity.prices.new
  end

  def create
    authorize! :update, @commodity
    @price = @commodity.prices.new(price_params)
    flash[:notice] = 'The price was created successfully.' if @price.save
    respond_with(@price, location: response_location)
  end

  def edit
    authorize! :update, @price
  end

  def update
    authorize! :update, @price
    @price.update_attributes(price_params)
    flash[:notice] = 'The price was updated successfully.' if @price.save
    respond_with(@price, location: response_location)
  end

  def destroy
    authorize! :destroy, @price
    flash[:notice] = 'The price was deleted successfully.' if @price.destroy
    respond_with(@price, location: response_location)
  end

  private

    def load_commodity
      @commodity = @price ? @price.commodity :  Commodity.find(params[:commodity_id])
    end

    def load_price
      @price = Price.find(params[:id])
    end

    def price_params
      result = params.require(:price).permit(:trade_date, :price)
      result[:trade_date] = Chronic.parse(result[:trade_date]) if result[:trade_date].present?
      result
    end

    def response_location
      commodity_prices_path(@commodity || @price.commodity)
    end

    def set_current_entity
      self.current_entity = (@commodity || @price.commodity).entity
    end
end
