class ApplicationController < ActionController::Base
  skip_forgery_protection
  before_action :set_current_user

  def set_current_user 
    if session[:user_id]
      Current.user = User.find_by(id: session[:user_id])
    end
  end

  def required_user_logged_in! 
    redirect_to sign_in_path, alert: "You must be signed in to tdo that." if Current.user.nil?
  end
  
end
