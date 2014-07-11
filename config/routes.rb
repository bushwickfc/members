Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root to: 'members#index'

  resources :members do
    resources :time_banks, module: :members
    resources :fees, module: :members
    resources :committees, only: [:index]
  end

  resources :committees
  resources :time_banks
  resources :fees
end
