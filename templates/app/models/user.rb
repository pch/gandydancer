class User < ActiveRecord::Base
  include Users::Auth

  validates :email, presence: true,
    uniqueness: true,
    email: true
end
