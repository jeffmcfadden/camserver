require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do

  devise_for :users

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
    
  resources :cameras
  resources :motion_events do
    collection do
      get '/calendar' => 'motion_events#calendar', as: :calendar
    end
  end
  
  
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
