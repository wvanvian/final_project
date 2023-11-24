Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "session#create"
  
  get "main", to: "main#index"

  get "sign_up", to: "registration#new"
  post "sign_up", to: "registration#create"

  get "logout", to: "session#destroy"

  get "sign_in", to: "session#new"
  post "sign_in", to: "session#create"

  get "upload", to: "data#upload"

  get "analyze", to: "data#analyze"

end
