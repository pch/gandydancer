class SignupsController < ApplicationController
  before_action :allow_anonymous_only

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email = @user.email.downcase

    if @user.save
      cookies[:auth_token] = @user.auth_token
      flash[:notice] = "Welcome aboard!"
      redirect_to root_path
    else
      render "new"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
