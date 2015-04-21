Rails.application.routes.draw do
  root 'maps#show'

  resource :map, only: :show do
    get :positioning
  end

  resources :jobs, only: :index
  resources :places, only: [:index, :show]
  resources :requests do
    resources :abuses, only: [:new, :create]
    resources :comments, only: [:index, :new, :create]
    resources :notes, only: [:index, :new, :create]
    resources :votes, only: [:new, :create]
  end
  resources :services, only: :index
end
