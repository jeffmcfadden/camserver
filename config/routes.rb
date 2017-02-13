require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do

  devise_for :users

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
    
  resources :cameras do
    member do
      post '/create_card_clone_worker', to: "cameras#create_card_clone_worker", as: :create_card_clone_worker
    end
  end
  
  resources :motion_events do
    collection do
      get '/calendar',               to: 'motion_events#calendar', as: :calendar
      get '/selected_from_timeline', to: 'motion_events#selected_from_timeline', as: :selected_from_timeline
      get '/favorites',              to: 'motion_events#favorites', as: :favorites
    end
    
    member do
      post '/favorite', to: 'motion_events#favorite', as: :favorite
      post '/unfavorite', to: 'motion_events#unfavorite', as: :unfavorite
    end
  end
  
  
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
