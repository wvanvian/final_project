class ApplicationController < ActionController::Base
  skip_forgery_protection
  before_action :set_current_user

  def set_current_user 
    if session[:user_id]
      Current.user = User.find_by(id: session[:user_id])
    end
  end
  
end
