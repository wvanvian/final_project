class RegistrationController < ApplicationController
  def new
    @user = User.new
  end

  def create

    pp("*******************")
    pp(params.fetch(:user, {}).permit(:first_name, :last_name, :username, :email, :password))
    pp("*******************")

    @user = User.new(params.fetch(:user, {}).permit(:first_name, :last_name, :username, :email, :password))
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Successfully created account"
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:fist_name, :last_name, :username, :email, :password)
  end

end
