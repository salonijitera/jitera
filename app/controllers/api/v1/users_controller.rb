class Api::V1::UsersController < ApplicationController
  before_action :validate_email_format, only: [:request_password_reset]

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

  private

  def validate_email_format
    unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
      render json: { error: "Invalid email format." }, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:email)
  end
end
