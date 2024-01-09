class Api::UsersController < ApplicationController
  before_action :validate_email_format, only: [:create_password_reset_request, :login]
  before_action :validate_email_existence, only: [:create_password_reset_request]
  before_action :validate_verification_token, only: [:verify_email]
  before_action :validate_registration_params, only: [:register]
  before_action :validate_login_params, only: [:login]

  # POST /api/users/reset_password
  def reset_password
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

    if result[:error]
      render json: { error: result[:error] }, status: (result[:error] == 'Invalid or expired password reset token.' ? :not_found : :unprocessable_entity)
      return
    end

    render json: { message: 'Password has been successfully reset.' }, status: :ok
  end

  # The rest of the methods (create_password_reset_request, verify_email, login, register) remain unchanged from the new code.
  # ...

  private
  
  # The private methods (validate_email_format, validate_verification_token, validate_registration_params, validate_login_params) remain unchanged from the new code.
  # ...

  def validate_email_existence
    user = User.find_by(email: params[:email])
    unless user
      render json: { error: 'Email not found.' }, status: :not_found
      return
    end

    unless user.email_verified?
      render json: { error: 'Email not verified.' }, status: :unauthorized
      return
    end
  end

  # The rescue_from StandardError block remains unchanged from the new code.
  # ...
end
