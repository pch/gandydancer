class SessionsController < ApplicationController
  before_action :allow_anonymous_only, except: [:destroy]

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end

      flash[:notice] = "Hello"
      redirect_to root_path
    else
      flash.now.alert = "Invalid email and/or password"
      render "new"
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, notice: "You signed out successfully"
  end
end
