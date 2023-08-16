Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  resources :employees
  
  # API
  namespace :api do
    post "login", to: "auth#index"
    get "restaurants", to: "restaurants#index"
    get "products", to: "products#index"
    get "orders", to: "orders#index"
    post "orders", to: "orders#create"
    post "order/:id/status", to: "orders#set_status"
    post "order/:id/rating", to: "orders#set_rating"
    get "account/:id", to: "auth#get_account"
    post "account/:id", to: "auth#update_account"
  end
end
