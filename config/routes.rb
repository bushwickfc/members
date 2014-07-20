Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root to: 'members#index'

  resources :members do
    resources :furloughs, module: :members, only: [:index]
    resources :holds, module: :members, except: [:destroy, :index]
    resources :parentals, module: :members, except: [:destroy, :index]
    resources :time_banks, module: :members
    resources :fees, module: :members
    resources :committees, only: [:index]
  end

  resources :committees do
    resources :time_banks, module: :committees
  end
  resources :time_banks
  resources :fees
end
