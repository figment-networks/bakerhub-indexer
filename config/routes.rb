Rails.application.routes.draw do
  namespace :tezos, defaults: { format: :json } do
    resources :blocks, only: [:index, :show]
    resources :cycles, only: [:index, :show] do
      resources :events, only: :index
    end
    resources :events, only: :index
    resources :bakers, only: [:index, :show] do
      get :count, on: :collection
    end
    resources :voting_periods, only: [:index, :show]
    resources :proposals, only: [:index, :show]
    resources :ballots, only: [:index, :show]
  end
end
