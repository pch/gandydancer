class GuestUser
  def id
    nil
  end

  def logged_in?
    false
  end

  def admin?
    false
  end

  def followed_by?(user)
    false
  end

  def wants?(product)
    false
  end

  def owns?(product)
    false
  end

  def mehs?(product)
    false
  end

  def loves?(product)
    false
  end
end
