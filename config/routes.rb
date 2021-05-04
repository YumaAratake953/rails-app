Rails.application.routes.draw do
  get '/login',to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  #get 'sessions/new'
  namespace :admin do
    resources :users
  end
  resources :works
  root to: 'works#index'
  post'/list',to: 'works#list'
  get'/list',to: 'works#list'
  get'/add', to: 'works#favorite_add'
  get'/favorite', to:'works#favorite_list'


  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
