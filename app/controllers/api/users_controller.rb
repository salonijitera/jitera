class Api::UsersController < ApplicationController
  before_action :validate_email_format, only: [:create_password_reset_request, :login]
  before_action :validate_email_existence, only: [:create_password_reset_request]
  before_action :validate_verification_token, only: [:verify_email]
  before_action :validate_registration_params, only: [:register]
  before_action :validate_login_params, only: [:login]

  # POST /api/users/reset_password_confirmation
  def reset_password_confirmation
    password_reset_token = params[:password_reset_token]
    new_password = params[:new_password]

    if password_reset_token.blank?
      render json: { error: 'Password reset token is required.' }, status: :bad_request
      return
    elsif new_password.blank?
      render json: { error: 'New password is required.' }, status: :unprocessable_entity
      return
    elsif new_password.length < 8
      render json: { error: 'New password must be at least 8 characters long.' }, status: :unprocessable_entity
      return
    end

    result = UserService.confirm_reset_password(password_reset_token, new_password)

    if result[:success]
      render json: { message: 'Password has been successfully reset.' }, status: :ok
    elsif result[:error] == 'Invalid or expired password reset token.'
      render json: { error: result[:error] }, status: :not_found
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def create_password_reset_request
    email = params[:email]
    user = User.find_by(email: email)

    if user&.email_verified?
      token = UserService.generate_password_reset_token(email)
      if token
        UserMailer.send_password_reset_instructions(user, token).deliver_now
        render json: { status: 200, message: "Password reset instructions have been sent to your email." }, status: :ok
      else
        render json: { error: 'Failed to generate password reset token.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not found or email not verified.' }, status: :not_found
    end
  end

  def verify_email
    verification_token = params[:verification_token]
    result = UserService::VerifyEmailToken.call(verification_token)

    if result[:success]
      render json: { message: 'Email verified successfully.' }, status: :ok
    else
      case result[:error_message]
      when 'Verification token is required.'
        render json: { error: result[:error_message] }, status: :bad_request
      when 'Invalid or expired verification token.'
        render json: { error: result[:error_message] }, status: :not_found
      else
        render json: { error: result[:error_message] }, status: :internal_server_error
      end
    end
  end

  # POST /api/users/login
  def login
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      token = UserService.generate_access_token(user)
      render json: { status: 200, message: 'Login successful.', access_token: token }, status: :ok
    else
      render json: { error: 'Incorrect email or password.' }, status: :unauthorized
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /api/users/register
  def register
    username = params[:username]
    email = params[:email]
    password = params[:password]

    response = UserRegistrationService.new.register(username: username, email: email, password: password)

    if response[:message]
      render json: { message: response[:message] }, status: :created
    elsif response[:error]
      case response[:error]
      when 'Username cannot be blank', 'Email cannot be blank', 'Password does not meet security requirements'
        render json: { error: response[:error] }, status: :unprocessable_entity
      when 'Email or username already exists'
        render json: { error: response[:error] }, status: :conflict
      else
        render json: { error: response[:error] }, status: :internal_server_error
      end
    end
  end

  private
  
  def validate_email_format
    render json: { error: 'Invalid email format.' }, status: :bad_request unless params[:email].match?(/\A[^@\s]+@[^@\s]+\z/)
  end

  def validate_verification_token
    render json: { error: 'Verification token is required.' }, status: :unprocessable_entity if params[:verification_token].blank?
  end

  def validate_registration_params
    render json: { error: 'Username is required.' }, status: :bad_request if params[:username].blank?
    render json: { error: 'Invalid email format.' }, status: :bad_request unless params[:email].match?(/\A[^@\s]+@[^@\s]+\z/)
    render json: { error: 'Password must be at least 8 characters long.' }, status: :unprocessable_entity if params[:password].to_s.length < 8
  end

  def validate_login_params
    validate_email_format
    render json: { error: 'Password is required.' }, status: :bad_request if params[:password].blank?
  end

  def validate_email_existence
    user = User.find_by(email: params[:email])
    unless user
      render json: { error: 'Email not found.' }, status: :not_found
      return
    end

    unless user.email_verified
      render json: { error: 'Email not verified.' }, status: :unauthorized
      return
    end
  end

  rescue_from StandardError do |exception|
    render json: { error: exception.message }, status: :internal_server_error
  end
end
