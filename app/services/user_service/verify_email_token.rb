class UserService::VerifyEmailToken < BaseService
  def call(verification_token)
    raise ArgumentError, 'Verification token cannot be empty' if verification_token.nil? || verification_token.strip.empty?

    user = User.find_by(verification_token: verification_token)

    if user
      UserMailer.send_email_verification_confirmation(user).deliver_now
      user.update(email_verified: true, verification_token: nil)
      { success: true, message: 'Email has been successfully verified.' }
    else
      { success: false, error_message: 'Invalid or expired verification token.' }
    end
  rescue => e
    Rails.logger.error "Email verification failed: #{e.message}"
    { success: false, error_message: e.message }
  end
end
