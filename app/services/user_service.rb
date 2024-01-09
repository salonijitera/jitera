class UserService < BaseService
  require 'jwt'

  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  PASSWORD_FORMAT = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}\z/

  def authenticate(email, password)
    begin
      user = User.find_by(email: email)
      raise ArgumentError, 'Invalid email format.' unless email =~ URI::MailTo::EMAIL_REGEXP
      raise ArgumentError, 'Password is required.' if password.blank?
      raise ArgumentError, 'Incorrect email or password.' unless user && BCrypt::Password.new(user.password_hash) == password

      access_token = generate_access_token(user.id)
      { status: 200, message: 'Login successful.', access_token: access_token }
    rescue ArgumentError => e
      logger.error "Authentication failed: #{e.message}"
      raise
    rescue => e
      logger.error "Internal Server Error: #{e.message}"
      raise
    end
  end

  private

  def generate_access_token(user_id)
    JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, SECRET_KEY)
  end

  def generate_password_reset_token(email)
    begin
      # Validate email format
      raise ArgumentError, 'Invalid email format' unless email =~ URI::MailTo::EMAIL_REGEXP

      # Find verified user by email
      user = User.find_by(email: email, email_verified: true)
      raise ArgumentError, 'User not found or not verified' unless user

      # Generate unique token
      token = Devise.friendly_token

      # Update user's password reset token and timestamp
      user.update!(password_reset_token: token, reset_password_sent_at: Time.now.utc)

      # Return the generated token
      token
    rescue => e
      # Log the error
      logger.error "Password reset token generation failed: #{e.message}"
      raise
    end
  end

  def self.confirm_reset_password(password_reset_token:, new_password:)
    return { error: I18n.t('activerecord.errors.messages.blank') } if password_reset_token.blank? || new_password.blank?

    unless new_password.match(PASSWORD_FORMAT)
      return { error: I18n.t('activerecord.errors.messages.invalid') }
    end

    user = User.find_by(password_reset_token: password_reset_token)
    return { error: I18n.t('activerecord.errors.messages.invalid') } unless user

    begin
      user.password_hash = BCrypt::Password.create(new_password)
      user.password_reset_token = nil
      if user.save
        { success: 'Password has been successfully reset.' }
      else
        { error: user.errors.full_messages.join(', ') }
      end
    rescue => e
      { error: e.message }
end
  end
end

# Note: BCrypt is assumed to be part of the Gemfile. If not, it should be added.
# gem 'bcrypt', '~> 3.1.7'

