require 'app/models/user.rb'
require 'app/models/email_verification_token.rb'

module UserService
  class Update
    PASSWORD_FORMAT = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}\z/

    def self.update_user_profile(user_id:, email:, password_hash:)
      User.transaction do
        user = User.find(user_id)

        raise ActiveRecord::RecordInvalid.new(user, :email) unless email =~ URI::MailTo::EMAIL_REGEXP
        raise ActiveRecord::RecordInvalid.new(user, :password_hash) unless password_hash =~ PASSWORD_FORMAT

        if user.email != email
          if User.exists?(email: email)
            raise ActiveRecord::RecordInvalid.new(user, :email)
          else
            user.update!(email: email, email_verified: false)
          end
        end

        encrypted_password = Devise::Encryptor.digest(User, password_hash)
        user.update!(password_hash: encrypted_password)

        token = user.email_verification_tokens.create!(token: SecureRandom.hex(10), expires_at: 24.hours.from_now, used: false)
        # Here you would initiate the email verification process, e.g., send an email with the token

        { user_id: user.id, email: user.email, email_verified: user.email_verified }
      end
    rescue ActiveRecord::RecordNotFound => e
      # Handle user not found error
    rescue ActiveRecord::RecordInvalid => e
      # Handle invalid record error
    end
  end
end
