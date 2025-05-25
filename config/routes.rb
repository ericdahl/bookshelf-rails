Rails.application.routes.draw do
  resources :series
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "books#index"

  namespace :api do
    namespace :v1 do
      resources :books # This will create routes for index, show, create, update, destroy
      resources :series # You can add this too
      get "search", to: "open_library_searches#search"
    end
  end

  resources :books do
    collection do
      get :search
      post :add_from_search
    end
    member do
      patch :update_status
    end
  end

  post 'books/restore', to: 'books#restore', as: 'restore_book'
end
