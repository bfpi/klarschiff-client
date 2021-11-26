# frozen_string_literal: true

Rails.application.routes.draw do
  root 'starts#show'

  resource :map, only: :show
  resource :start, only: :show

  resources :areas, only: :index
  resources :jobs, only: %i[index update]
  get 'jobs/notification', to: 'jobs#notification'

  resources :observations, only: %i[index new create]
  resources :places, only: %i[index show]
  resources :requests do
    resources :abuses, only: %i[new create]
    resources :comments, only: %i[index new create]
    resources :notes, only: %i[index new create]
    resources :photos, only: [:create]
    resources :protocols, only: %i[new create]
    resources :votes, only: %i[new create]
  end
  resources :services, only: :index
  resources :confirmations, only: [] do
    with_options only: [] do
      get :abuse
      get :issue
      get :photo
      get :revoke_issue
      get :vote
    end
  end
  resource :static do
    get :api
    get :help
    get :imprint
    get :privacy
    get :promotion
    get :usage
    get :requests, to: redirect('/static/requests/1')
    get 'requests/:page', to: 'statics#request', as: :requests_page
  end
  resources :statistics, only: :index
end
