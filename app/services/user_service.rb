
class UserService < BaseService
  require 'jwt'
  require 'bcrypt'

  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  PASSWORD_FORMAT = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}\z/

  def authenticate(email, password)
    begin
      user = User.find_by(email: email)
      raise ArgumentError, 'Invalid email format.' unless email.match?(URI::MailTo::EMAIL_REGEXP)
      raise ArgumentError, 'Password is required.' if password.blank?
      raise ArgumentError, 'Incorrect email or password.' unless user && user.email_verified && BCrypt::Password.new(user.password_hash) == password

      access_token = generate_access_token(user.id)
      { status: 200, message: 'Login successful.', access_token: access_token }
    rescue ArgumentError => e
      logger.error "Authentication failed: #{e.message}"
      { status: 401, message: e.message }
    rescue => e
      logger.error "Internal Server Error: #{e.message}"
      raise
    end
  end

  def generate_password_reset_token(email)
    begin
      # Validate email format
      raise ArgumentError, 'Invalid email format' unless email =~ URI::MailTo::EMAIL_REGEXP

      # Find user by email
      user = User.find_by(email: email)
      raise ArgumentError, 'User not found or not verified' unless user && user.email_verified

      # Generate unique token
      token = Devise.friendly_token

      # Update user's password reset token and timestamp
      user.update!(password_reset_token: token, reset_password_sent_at: Time.now.utc)

      # Return the generated token and email
      { token: token, email: user.email }
    rescue => e
      # Log the error
      logger.error "Password reset token generation failed: #{e.message}"
      raise
    end
  end

  def self.confirm_reset_password(password_reset_token:, new_password:)
    return { status: 400, error: "Password reset token is required." } if password_reset_token.blank?
    return { status: 400, error: "New password must be at least 8 characters long." } if new_password.length < 8
    return { status: 422, error: "New password must be at least 8 characters long." } unless new_password.match(PASSWORD_FORMAT)

    user = User.find_by(password_reset_token: password_reset_token)
    return { status: 404, error: "Invalid or expired password reset token." } unless user

    begin
      user.password_hash = BCrypt::Password.create(new_password)
      user.password_reset_token = nil
      if user.save(context: :reset_password)
        { status: 200, message: 'Password reset successfully.' }
      else
        { status: 400, error: user.errors.full_messages.join(', ') }
      end
    rescue => e
      { status: 500, error: e.message }
    end
  end

  private

  def generate_access_token(user_id)
    JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, SECRET_KEY)
  end
end
