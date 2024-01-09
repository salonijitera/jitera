require_relative '../../services/shop_service/update'
require_relative '../../services/user_verification_service'
require_relative '../../services/user_service/update'
require_relative '../../policies/shop_policy'
require_relative '../../policies/application_policy'
require_relative '../../models/user'
require_relative '../../models/email_verification_token'

module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:verify_email]
    before_action :set_user, only: [:update_shop]
    before_action :authorize_shop_update, only: [:update_shop]

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

    def update_shop
      begin
        validate_shop_params
        service = ShopService::Update.new(params[:id], params[:shop_name], params[:shop_description], current_user)
        result = service.call
        if result[:error]
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { status: 200, message: "Shop information updated successfully." }, status: :ok
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found." }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    def verify_email
      token = params.require(:token)

      begin
        result = UserVerificationService.verify_email(nil, token)

        if result[:status] == 'success'
          render json: { status: 200, message: 'Email verified successfully.' }, status: :ok
        else
          render json: { message: result[:message] }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'Invalid verification token.' }, status: :not_found
      rescue StandardError => e
        if e.message == 'Verification failed: Token is invalid or has expired.'
          render json: { message: 'The verification token has expired.' }, status: :unprocessable_entity
        else
          render json: { message: 'An unexpected error occurred on the server.' }, status: :internal_server_error
        end
      end
    end

    private

    def authenticate_user!
      # Implement user authentication logic here
    end

    def set_user
      @user = User.find(params[:id])
    end

    def authorize_shop_update
      authorize @user, policy_class: ShopPolicy
    end

    def validate_shop_params
      raise "Shop name is required." if params[:shop_name].blank?
      raise "Shop description cannot exceed 1000 characters." if params[:shop_description].length > 1000
    end
  end
end
