require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Routes from the new code
  namespace :api do
    post '/users/request-password-reset', to: 'users#create_password_reset_request'
  end

  # Routes from the existing code
  post '/api/users/login', to: 'api/users#login'
  post '/api/users/register', to: 'api/users#register'
  post '/api/users/reset-password', to: 'api/users#reset_password_confirmation'
  post '/api/users/verify-email', to: 'users#verify_email'

  # ... other routes ...
end
