module Users
  module Auth
    extend ActiveSupport::Concern

    included do
      has_secure_password

      validates :password, presence: { unless: :persisted? },
        length: { minimum: 6 }, allow_nil: true

      attr_accessor :current_password

      before_create { generate_token(:auth_token) }
    end

    module ClassMethods
      def by_insensitive_email(email)
        where("lower(email) = ?", email.downcase).first
      end
    end

    def logged_in?
      true
    end

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      UserMailer.password_reset(self).deliver
    end

    def admin?
      role == 'admin'
    end

    private

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
  end
end
