Rails.application.routes.draw do
  root 'maps#show'

  resources :jobs, only: :index
  resource :map, only: :show
  resources :places, only: [:index, :show]
  resources :requests do
    resources :abuses, only: [:new, :create]
    resources :comments, only: [:index, :new, :create]
    resources :notes, only: [:index, :new, :create]
    resources :votes, only: [:new, :create]
  end
end
