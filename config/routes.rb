require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
    
  resources :cameras
  resources :motion_events
  
  
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
