module Auth
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token])
    @current_user ||= GuestUser.new
  end

  def authorize
    redirect_to login_url, alert: "Log in first"  unless current_user.logged_in?
  end

  def authorize_owner(owner)
    redirect_to root_url, alert: "Permision denied" if current_user != owner
  end

  def allow_anonymous_only
    redirect_to root_url, alert: "You're already logged in" if current_user.logged_in?
  end

  def authorize_admin
    redirect_to root_url, alert: "Permission denied"  unless current_user.admin?
  end
end
