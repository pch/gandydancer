class PasswordResetsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset if user

    redirect_to root_url, notice: t('passwords.reset_email_sent')
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])

    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, alert: "Link has expired. Try again."
    elsif @user.update_attributes(user_params)
      @user.update_attributes(password_reset_token: nil)

      redirect_to root_url, notice: "Password was successfully changed"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password)
  end
end
