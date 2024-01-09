require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # The new route for user registration is added here
  post '/api/users/register', to: 'users#register'

  # The existing routes for users are maintained
  resources :users, only: [] do
    member do
      put 'profile', to: 'users#update'
    end
  end

  # ... other routes ...
end
