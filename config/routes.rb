Rails.application.routes.draw do
  root 'maps#show'

  resource :map, only: :show
  resources :places, only: [:index, :show]
  resources :requests
end
