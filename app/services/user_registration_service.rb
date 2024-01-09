class UserRegistrationService < BaseService
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

    send_confirmation_email(user)

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

  def send_confirmation_email(user)
    ActionMailer::Base.mail(
      from: 'noreply@example.com',
      to: user.email,
      subject: I18n.t('devise.mailer.confirmation_instructions.subject'),
      body: render_to_string(
        template: '/app/views/devise/mailer/confirmation_instructions.html.slim',
        locals: { email: user.email, token: user.verification_token }
      )
    ).deliver_now
  end
end
