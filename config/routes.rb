
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Consolidated routes from both the new and existing code
  namespace :api do
    # Routes from the new code
    post '/users/request-password-reset', to: 'users#create_password_reset_request'
    post '/users/verify-email', to: 'users#verify_email'
    post '/users/password-reset/initiate', to: 'users#initiate_password_reset'

    # Routes from the existing code
    post '/users/login', to: 'users#login'
    post '/users/register', to: 'users#register'
    post '/users/reset-password', to: 'users#reset_password_confirmation'
  end

  # ... other routes ...
end
