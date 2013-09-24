class EntitiesController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :json
  
  def index
    respond_with @entities
  end

  def show
    respond_with @entity
  end

  def new
  end

  def create
    @entity = current_user.entities.new(params[:entity])
    flash[:notice] = 'The entity was created successfully.' if @entity.save
    respond_with @entity
  end

  def edit
  end

  def update
    @entity.update_attributes(params[:entity])
    flash[:notice] = 'The entity was updated successfully.' if @entity.save
    respond_with @entity
  end

  def destroy
    @entity.destroy
    flash[:notice] = 'The entity was removed successfully.'
    respond_with @entity
  end
end
