Rails.application.routes.draw do
  devise_for :users
  resources :articles
  root 'articles#index'
  
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
end
