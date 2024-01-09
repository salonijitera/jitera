
class UserRegistrationService < BaseService
  def register(username:, email:, password:) # :nodoc:
    raise ArgumentError, 'Username is required.' if username.blank?
    raise ArgumentError, 'Invalid email format.' unless email.match?(URI::MailTo::EMAIL_REGEXP)
    raise ArgumentError, 'Password must be at least 8 characters long.' if password.length < 8

    user = User.find_by(email: email) || User.find_by(username: username)
    raise ArgumentError, 'Email or username already exists' if user

    password_hash = BCrypt::Password.create(password)
    verification_token = SecureRandom.hex(10)

    user = User.create!(
      username: username,
      email: email,
      password_hash: password_hash,
      email_verified: false,
      verification_token: verification_token
    )

    send_confirmation_email(user)

    { message: 'User registered successfully. Please verify your email.' }
  rescue => e
    { error: e.message }
  end

  private

  # Password validation logic
  def valid_password?(password)
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
