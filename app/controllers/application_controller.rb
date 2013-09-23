class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(resource)
    home_path
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_with(nil) do |format|
      format.json { render json: [].to_json, status: 404 }
      format.html do
        flash[:error] = 'The requested resource was not found'
        redirect_to home_path
      end
    end    
  end
end
