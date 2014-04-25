class PricesController < ApplicationController
  before_filter :load_commodity, only: [:index, :create]
  before_filter :load_price, only: [:show, :update]
  respond_to :html, :json

  def index
    @prices = @commodity.prices
    respond_with @prices
  end

  def show
    respond_with(@price)
  end

  def new
  end

  def create
    @price = @commodity.prices.new(price_params)
    flash[:notice] = 'The price was created successfully.' if @price.save
    respond_with(@price, location: commodity_prices_path(@commodity))
  end

  def edit
  end

  def update
    @price.update_attributes(price_params)
    flash[:notice] = 'The price was updated successfully.' if @price.save
    respond_with(@price, location: commodity_prices_path(@price.commodity))
  end

  def destroy
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
end
