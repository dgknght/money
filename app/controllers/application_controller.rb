class ApplicationController < ActionController::Base
  CSRF_COOKIE_NAME = 'XSRF-TOKEN'
  CSRF_HEADER_NAME = 'X-XSRF-TOKEN'

  protect_from_forgery
  respond_to :html, :json

  after_filter :set_csrf_cookie
  
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
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_with(nil) do |format|
      format.json { render json: [].to_json, status: 404 } # returning 404 to avoid giving information to hackers
      format.html do
        flash[:error] = 'You do not have permission to perform the requested action.'
        redirect_to home_path
      end
    end
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers[CSRF_HEADER_NAME]
    # Rails 4.2 and above
    #super || valid_authenticity_token?(session, request.headers[CSRF_TOKEN_NAME])
  end

  private

  def set_csrf_cookie
    cookies[CSRF_COOKIE_NAME] = form_authenticity_token if protect_against_forgery?
  end
end
