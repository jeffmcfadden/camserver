Rails.application.routes.draw do

  devise_for :users
  
  resources :cameras
  resources :motion_events
  
  
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
