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
    @importer = GnucashImporter.new
  end

  def create
    @entity = current_user.entities.new(entity_params)
    flash[:notice] = 'The entity was created successfully.' if @entity.save && import
    respond_with @entity, location: entity_accounts_path(@entity)
  end

  def edit
  end

  def update
    @entity.update_attributes(entity_params)
    flash[:notice] = 'The entity was updated successfully.' if @entity.save
    respond_with @entity, location: entities_path
  end

  def destroy
    @entity.fast_destroy!
    flash[:notice] = 'The entity was removed successfully.'
    respond_with @entity
  end
  
  private
    def import
      return true unless import_params.has_key?('data')

      @importer = GnucashImporter.new(import_params)
      @importer.import!
      flash[:notice] = 'The information was imported successfully.'
      true
    rescue StandardError => e
      @error_message = e.message
      false
    end

    def set_current_entity
      self.current_entity = @entity
    end
    
    def entity_params
      params.require(:entity).permit(:name)
    end

    def import_params
      params.require(:entity).permit(:data).merge(entity: @entity)
    end
end
