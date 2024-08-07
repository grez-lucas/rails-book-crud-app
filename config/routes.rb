Rails.application.routes.draw do
  root 'home#index'
  resources :sales
  resources :reviews
  resources :books
  resources :authors
  get 'books/top_selling', to: 'books#top_selling', as: 'top_selling_books'
  get 'books/top_rated', to: 'books#top_rated', as: 'top_rated_books'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
