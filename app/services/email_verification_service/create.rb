require 'app/models/email_verification_token.rb'
require 'securerandom'

module EmailVerificationService
  class Create
    def self.generate_email_verification_token(user)
      begin
        # Use SecureRandom to generate the token
        token_value = SecureRandom.hex(10)
        expires_at = 24.hours.from_now

        # Create a new EmailVerificationToken object with the generated values
        token = EmailVerificationToken.new(
          token: token_value,
          expires_at: expires_at,
          user: user
        )
        token.save!

        # Placeholder for sendEmail function (actual implementation depends on the project's email service setup)
        sendEmail(user.email, token.token)

        token
      rescue => e
        # Handle exceptions, possibly log them or re-raise with a custom message
        raise "Failed to generate email verification token: #{e.message}"
      end
    end

    private

    # Define the sendEmail function or integrate with the project's email service
    def self.sendEmail(email, token)
      # TODO: Implement the email sending logic here
      # This is a placeholder method. The actual implementation should send an email with the verification token.
    end
  end
end
