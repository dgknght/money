class PricesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_commodity, only: [:index, :new, :create]
  before_filter :load_price, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json

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
      @commodity = Commodity.find(params[:commodity_id])
    end

    def load_price
      @price = Price.find(params[:id])
    end

    def price_params
      params.require(:price).permit(:trade_date, :price)
    end

    def response_location
      commodity_prices_path(@commodity || @price.commodity)
    end
end