class UserRegistrationService
  def register(username:, email:, password:)
    raise ArgumentError, 'Username cannot be blank' if username.blank?
    raise ArgumentError, 'Email cannot be blank' if email.blank?
    raise ArgumentError, 'Password does not meet security requirements' unless valid_password?(password)

    user = User.find_by(email: email) || User.find_by(username: username)
    raise ArgumentError, 'Email or username already exists' if user

    password_hash = BCrypt::Password.create(password)
    verification_token = generate_verification_token

    user = User.create!(
      username: username,
      email: email,
      password_hash: password_hash,
      email_verified: false,
      verification_token: verification_token
    )

    UserMailer.send_confirmation_email(user, verification_token).deliver_now

    { message: 'User registered successfully. Please verify your email.' }
  rescue StandardError => e
    { error: e.message }
  end

  private

  def valid_password?(password)
    # Implement password validation logic here
    password.length >= 8
  end

  def generate_verification_token
    SecureRandom.hex(10)
  end
end
