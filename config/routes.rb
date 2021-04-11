Rails.application.routes.draw do
  resources :works
  root to: 'works#index'
  post'/list',to: 'works#list'
  get'/list',to: 'works#list'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
