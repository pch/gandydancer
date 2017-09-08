class User < ActiveRecord::Base
  include Users::Auth

  validates :email, presence: true,
    uniqueness: true,

  validates_with EmailAddress::ActiveRecordValidator, field: :email
end
