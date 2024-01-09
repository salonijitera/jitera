require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    # Routes from the new code
    post '/users/request-password-reset', to: 'users#create_password_reset_request'
    post '/users/verify-email', to: 'users#verify_email'
    post '/users/login', to: 'v1/users#login' # Updated to point to v1/users#login
    post '/users/register', to: 'users#register'
    
    # Routes from the existing code
    post '/users/password-reset/confirm', to: 'users#reset_password'
    post '/users/password-reset/initiate', to: 'users#initiate_password_reset'
    
    # Combined route from new and existing code
    post '/users/reset-password', to: 'users#reset_password_confirmation'
  end

  # ... other routes ...
end
