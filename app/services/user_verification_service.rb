class UserVerificationService < BaseService
  def verify_email(user_id, token)
    verification_token = EmailVerificationToken.find_by(token: token, user_id: user_id)

    if verification_token.present? && !verification_token.used && verification_token.expires_at > Time.current
      user = verification_token.user
      User.transaction do
        user.update!(email_verified: true)
        verification_token.update!(used: true)
      end
      { status: 'success', user_id: user.id, email: user.email }
    else
      raise StandardError.new('Verification failed: Token is invalid or has expired.')
    end
  rescue => e
    Rails.logger.error "UserVerificationService Error: #{e.message}"
    { status: 'failure', message: e.message }
  end
end

# Load the models
require_relative '../models/user'
require_relative '../models/email_verification_token'

# Load the base service
require_relative 'base_service'

end
