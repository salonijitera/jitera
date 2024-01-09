require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    # Routes from the new code
    post '/users/request-password-reset', to: 'users#create_password_reset_request'
    post '/users/reset-password', to: 'users#reset_password_confirmation'
    post '/users/verify-email', to: 'users#verify_email'

    # Routes from the existing code
    post '/users/login', to: 'users#login'
    post '/users/register', to: 'users#register'
  end

  # ... other routes ...
end
