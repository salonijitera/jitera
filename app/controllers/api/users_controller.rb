
class Api::UsersController < ApplicationController
  before_action :validate_email_format, only: [:create_password_reset_request]
  before_action :validate_verification_token, only: [:verify_email]

  # POST /api/users/reset_password_confirmation
  def reset_password_confirmation
    password_reset_token = params[:password_reset_token]
    new_password = params[:new_password]

    if password_reset_token.blank? || new_password.blank?
      render json: { error: 'Token and new password are required.' }, status: :unprocessable_entity
      return
    end

    result = UserService.confirm_reset_password(password_reset_token, new_password)

    if result[:success]
      render json: { message: 'Password has been successfully reset.' }, status: :ok
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
        head :ok, message: I18n.t('devise.passwords.send_instructions')
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
      render json: { status: 200, message: 'Email verified successfully.' }, status: :ok
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

  private
  
  def validate_email_format
    render json: { error: 'Invalid email format.' }, status: :bad_request unless params[:email].match?(/\A[^@\s]+@[^@\s]+\z/)
  end

  def validate_verification_token
    render json: { error: 'Verification token is required.' }, status: :unprocessable_entity if params[:verification_token].blank?
  end

  rescue_from StandardError do |exception|
    render json: { error: exception.message }, status: :internal_server_error
  end
end
