Rails.application.routes.draw do
  root 'starts#show'

  resource :map, only: :show
  resource :start, only: :show

  resources :areas, only: :index
  resources :jobs, only: [:index, :update]
  get 'jobs/notification', to: 'jobs#notification'

  resources :observations, only: [:index, :new, :create]
  resources :places, only: [:index, :show]
  resources :requests do
    resources :abuses, only: [:new, :create]
    resources :comments, only: [:index, :new, :create]
    resources :notes, only: [:index, :new, :create]
    resources :photos, only: [:create]
    resources :protocols, only: [:new, :create]
    resources :votes, only: [:new, :create]
  end
  resources :services, only: :index
  resources :confirmations, only: [] do
    with_options only: %i[edit] do
      get :issue
      get :vote
      get :abuse
      get :photo
    end
  end
  resource :static do
    get :api
    get :help
    get :imprint
    get :privacy
    get :promotion
    get :usage
    get :requests
    get 'requests/:page', to: 'statics#requests'
  end
  resources :statistics, only: :index
end
