Rails.application.routes.draw do
  root 'starts#show'

  resource :map, only: :show
  resource :start, only: :show

  resources :areas, only: :index
  resources :jobs, only: [:index, :update]
  resources :observations, only: [:index, :new, :create]
  resources :places, only: [:index, :show]
  resources :requests do
    resources :abuses, only: [:new, :create]
    resources :comments, only: [:index, :new, :create]
    resources :notes, only: [:index, :new, :create]
    resources :protocols, only: [:new, :create]
    resources :votes, only: [:new, :create]
  end
  resources :services, only: :index
  resource :static do
    get :api
    get :imprint
    get :privacy
    get :usage
  end
end
