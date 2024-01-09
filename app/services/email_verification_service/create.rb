module EmailVerificationService
  class Create
    require 'securerandom'

    def self.create_verification_token(user)
      token = SecureRandom.hex(10)
      expires_at = 24.hours.from_now

      email_verification_token = EmailVerificationToken.create!(
        token: token,
        expires_at: expires_at,
        used: false,
        user: user
      )

      # TODO: Implement the email sending logic here

      email_verification_token
    end
  end
end
