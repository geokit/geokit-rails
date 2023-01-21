Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # get "/", controller: :LocationAware, action: :index
  match ':controller(/:action(/:id(.:format)))', via: [:get, :post]
end
