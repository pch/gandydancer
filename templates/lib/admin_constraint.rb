class AdminConstraint
  def matches?(request)
    cookie = request.cookie_jar.permanent["auth_token"]
    return false unless cookie.present?

    user = User.find_by_auth_token(cookie)
    user && user.admin?
  end
end
