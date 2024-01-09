require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  post '/api/users/login', to: 'api/users#login'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # New route from the new code
  post '/api/users/register', to: 'api/users#register'

  # Existing routes from the existing code
  post '/api/users/reset-password', to: 'api/users#reset_password_confirmation'
  post '/api/users/verify-email', to: 'users#verify_email'

  # ... other routes ...
end
