Rails.application.routes.draw do
  resources :sales
  resources :reviews
  resources :books do
    collection do
      post 'create_index'
    end
  end
  resources :authors
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'home#index'
  get 'top_sellings', to: "books#top_selling"
  get 'top_rated', to: "books#top_rated"
end
