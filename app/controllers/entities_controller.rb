class EntitiesController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:new, :create]
  before_filter :set_current_entity
  respond_to :html, :json
  
  def index
    respond_with @entities
  end

  def show
    respond_with @entity
  end

  def new
    @entity = current_user.entities.new
  end

  def create
    @entity = current_user.entities.new(entity_params)
    flash[:notice] = 'The entity was created successfully.' if @entity.save
    respond_with @entity
  end

  def edit
  end

  def import
  end

  def update
    @entity.update_attributes(entity_params)
    flash[:notice] = 'The entity was updated successfully.' if @entity.save
    respond_with @entity
  end

  def destroy
    @entity.destroy
    flash[:notice] = 'The entity was removed successfully.'
    respond_with @entity
  end
  
  private
    def set_current_entity
      self.current_entity = @entity
    end
    
    def entity_params
      params.require(:entity).permit(:name)
    end
end
