class Api::V1::UsersController < ApplicationController
  include UserService

  before_action :validate_email_format, only: [:request_password_reset, :initiate_password_reset]
  before_action :validate_password_format, only: [:reset_password]
  before_action :user_params, only: [:register]
  rescue_from StandardError, with: :handle_internal_server_error

  # POST /api/users/register
  def register
    begin
      result = UserRegistrationService.new.register(
        username: params[:user][:username],
        email: params[:user][:email],
        password: params[:user][:password]
      )
      if result[:error].present?
        render json: { error: result[:error] }, status: :unprocessable_entity
      else
        render 'api/users/register', status: :created
      end
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  # POST /api/users/login
  def login
    username = params[:username]
    password = params[:password]

    if username.blank?
      return render json: { error: "Username is required." }, status: :bad_request
    end

    if password.blank?
      return render json: { error: "Password is required." }, status: :bad_request
    end

    @login_response = authenticate(username, password)

    if @login_response[:status] == 200
      render 'api/users/login', status: :ok
    else
      render json: { error: @login_response[:message] }, status: :unauthorized
    end
  end

  # POST /api/users/verify-email
  def verify_email
    result = UserService::VerifyEmailToken.call(params[:verification_token])

    if result[:success]
      render json: { status: 200, message: result[:message] }, status: :ok
    else
      case result[:error_message]
      when 'Invalid or expired verification token.'
        render json: { error: result[:error_message] }, status: :not_found
      else
        render json: { error: result[:error_message] }, status: :bad_request
      end
    end
  end

  # POST /api/users/request-password-reset
  def request_password_reset
    user = User.find_by(email: params[:email])

    if user
      token = user.generate_password_reset_token!
      UserMailer.send_password_reset_instructions(user, token).deliver_now
      render json: { status: 200, message: "Password reset email sent successfully." }, status: :ok
    else
      render json: { error: "Email not found." }, status: :not_found
    end
  end

  # POST /api/users/password-reset/initiate
  def initiate_password_reset
    user = User.find_by(email: params[:email])

    if user
      token_data = UserService.new.generate_password_reset_token(params[:email])
      if token_data[:token]
        UserMailer.send_password_reset_instructions(user, token_data[:token]).deliver_now
        render json: { status: 200, message: "Password reset instructions have been sent to your email." }, status: :ok
      else
        render json: { error: "Email address not found." }, status: :not_found
      end
    else
      render json: { error: "Invalid email address." }, status: :bad_request
    end
  end

  # POST /api/users/password-reset/confirm
  def reset_password
    result = UserService.reset_password(
      password_reset_token: params[:password_reset_token],
      new_password: params[:new_password]
    )

    if result[:message]
      render 'api/users/reset_password_confirmation', status: :ok, locals: { status_code: 200, error_message: nil }
    elsif result[:error] == 'Invalid or expired password reset token.'
      render 'api/users/reset_password_confirmation', status: :not_found, locals: { status_code: 404, error_message: result[:error] }
    elsif result[:error] == 'Password must be at least 8 characters long.'
      render 'api/users/reset_password_confirmation', status: :unprocessable_entity, locals: { status_code: 422, error_message: result[:error] }
    else
      render 'api/users/reset_password_confirmation', status: :internal_server_error, locals: { status_code: 500, error_message: result[:error] }
    end
  end

  private

  def handle_internal_server_error(exception)
    render json: { error: 'An unexpected error occurred on the server.' }, status: :internal_server_error
  end

  def validate_email_format
    unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i) || params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Invalid email format." }, status: :unprocessable_entity
    end
  end

  def validate_password_format
    render json: { error: "Password must be at least 8 characters long." }, status: :unprocessable_entity unless params[:new_password].length >= 8
  end

  def user_params
    params.require(:user).permit(:username, :email, :password)
  rescue ActionController::ParameterMissing
    render json: { error: "Missing user parameters" }, status: :bad_request
  end
end
