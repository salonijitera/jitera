require_relative '../../services/user_service/create'
require_relative '../../services/user_service/update'
require_relative '../../policies/application_policy'
require_relative '../../models/user'

module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:register]

    # POST /api/users/register
    def register
      begin
        validate_register_params(params)

        user = UserService::Create.create_user(
          username: params[:username],
          email: params[:email],
          password_hash: hash_password(params[:password])
        )

        render json: { status: 201, message: "User registered successfully. Please check your email to verify your account." }, status: :created
      rescue ArgumentError => e
        render json: { error: e.message }, status: :bad_request
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "Username or email is already in use." }, status: :conflict
      rescue StandardError => e
        render json: { error: "An unexpected error occurred." }, status: :internal_server_error
      end
    end

    def update
      user_id = params[:id].to_i
      username = params[:username]
      email = params[:email]

      begin
        raise ArgumentError, 'Invalid user ID format.' unless user_id.is_a?(Integer)

        user = User.find(user_id)
        authorize user

        if email.present?
          raise ArgumentError, 'Invalid email format.' unless email =~ URI::MailTo::EMAIL_REGEXP
        end

        updated_attributes = {}
        updated_attributes[:username] = username if username.present?
        updated_attributes[:email] = email if email.present?

        UserService::Update.update_user_profile(user_id: user.id, **updated_attributes)

        render json: { status: 200, message: 'Profile updated successfully.' }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found.' }, status: :not_found
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue Pundit::NotAuthorizedError
        render json: { error: 'Unauthorized' }, status: :unauthorized
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    private

    def authenticate_user!
      # Implement user authentication logic here
    end

    def validate_register_params(params)
      raise ArgumentError, "Username is required." if params[:username].blank?
      raise ArgumentError, "Invalid email format." unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
      raise ArgumentError, "Password must be at least 8 characters long." if params[:password].length < 8
    end

    def hash_password(password)
      # Assuming there's a method to hash the password
      Digest::SHA256.hexdigest(password)
    end
  end
end
