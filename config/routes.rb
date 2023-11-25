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
  post "upload_file", to: "data#upload_file"

  get "analyze", to: "data#analyze"
  post "analyze_file", to: "data#analyze_file"

  get "visualize", to: "data#visualize"

end
