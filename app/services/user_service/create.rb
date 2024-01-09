module UserService
  class Create
    def self.create_user(username:, email:, password_hash:)
      raise ArgumentError, 'Username cannot be blank' if username.blank?
      raise ArgumentError, 'Email cannot be blank' if email.blank?
      raise ArgumentError, 'Invalid password hash' unless valid_password_hash?(password_hash)

      if User.exists?(email: email)
        raise ArgumentError, 'Email is already registered'
      end

      user = User.create!(
        username: username,
        email: email,
        password_hash: password_hash,
        email_verified: false,
        created_at: Time.current
      )

      token = generate_verification_token(user)

      EmailService.send_email(
        to: user.email,
        subject: 'Verify Your Email',
        body: "Please verify your email by using this token: #{token}"
      )

      user
    end

    private

    def self.valid_password_hash?(password_hash)
      # Assuming there's a method to validate password hash according to security standards
      password_hash.match?(/\A[a-f0-9]{64}\z/)
    end

    def self.generate_verification_token(user)
      token = SecureRandom.hex(10)
      EmailVerificationToken.create!(token: token, user: user, expires_at: 24.hours.from_now, used: false)
      token
    end
  end
end
