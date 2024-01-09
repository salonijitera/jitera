
class Api::V1::UsersController < ApplicationController
  before_action :validate_email_format, only: [:initiate_password_reset]

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

  private

  def validate_email_format
    unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Invalid email format." }, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:email)
  end
end
