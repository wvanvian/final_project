class SessionController < ApplicationController
  def destroy
    session[:user_id] = nil
    redirect_to sign_in_path, notice: "Logged out"
  end

  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:email])
     
    if user.present? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to main_path, notice: "Logged in successfully"
    else
      flash[:alert] = "Invalid email or password"
      render :new
    end
  end

end
