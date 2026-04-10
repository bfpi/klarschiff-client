Rails.application.routes.draw do
  root 'starts#show'

  resource :map, only: :show
  resource :start do
    get :show
    get :recent_requests
  end

  resources :areas, only: :index
  resources :jobs, only: [:index, :update]
  get 'jobs/notification', to: 'jobs#notification'

  resources :observations, only: [:index, :new, :create]
  resources :places, only: [:index, :show]
  resources :requests do
    resources :abuses, only: [:new, :create]
    resources :comments, only: [:index, :new, :create]
    resources :completions, only: %i[new create]
    resources :notes, only: [:index, :new, :create]
    resources :photos, only: [:create]
    resources :protocols, only: [:new, :create]
    resources :votes, only: [:new, :create]
  end
  resources :services, only: :index
  resources :confirmations, only: [] do
    with_options only: [] do
      get :abuse
      get :completion
      get :issue
      get :photo
      get :revoke_issue
      get :vote
    end
  end
  resource :static do
    get :api
    get :contact
    get :finance
    get :help
    get :imprint
    get :news
    get :participation
    get :privacy
    get :promotion
    get 'requests/:page', to: 'statics#requests', as: :requests_page
    get :requests, to: redirect('/static/requests/1')
    get :usage
  end
  resources :statistics, only: :index
end
