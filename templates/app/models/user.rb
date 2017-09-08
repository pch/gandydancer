class User < ActiveRecord::Base
  include Users::Auth

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates_with EmailAddress::ActiveRecordValidator, field: :email
end
