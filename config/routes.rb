Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "main#index"

  get "sign_up", to: "registration#new"
  post "sign_up", to: "registration#create"

end
