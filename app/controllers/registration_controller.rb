class RegistrationController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params.fetch(:user, {}).permit(:first_name, :last_name, :username, :email, :password))
    
    if @user.save
      session[:user_id] = @user.id
      redirect_to main_path, notice: "Successfully created account"
    else
      render :new
    end
  end

end
