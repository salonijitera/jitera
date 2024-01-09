class Api::UsersController < ApplicationController
  before_action :validate_email_format, only: [:create_password_reset_request]

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

  private

  def validate_email_format
    render json: { error: 'Invalid email format.' }, status: :bad_request unless params[:email].match?(/\A[^@\s]+@[^@\s]+\z/)
  end
end
