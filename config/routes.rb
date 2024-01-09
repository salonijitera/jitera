require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # New route from the new code
  put '/api/users/:id/shop', to: 'users#update_shop', as: 'update_user_shop'

  resources :users, only: [] do
    member do
      put 'profile', to: 'users#update'
    end
  end

  # Existing route from the existing code
  post '/api/users/verify-email' => 'users#verify_email'
  # ... other routes from the existing code ...
end
