Rails.application.routes.draw do
  namespace :tezos, defaults: { format: :json } do
    resources :blocks, only: [:index, :show]
    resources :cycles, only: [:index, :show] do
      resources :events, only: :index
    end
    resources :bakers, only: [:index, :show]
  end
end
