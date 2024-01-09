class UserService < BaseService
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
end

# Note: BaseService is assumed to be a part of the application's service layer hierarchy.
# The logger method is assumed to be defined in BaseService or included as a concern.
