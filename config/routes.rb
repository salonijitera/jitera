require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  post '/api/users/reset-password', to: 'api/users#reset_password_confirmation'
  post '/api/users/verify-email', to: 'users#verify_email'
end
