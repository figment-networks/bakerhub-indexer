Rails.application.routes.draw do
  namespace :tezos, defaults: { format: :json } do
    resources :blocks, only: [:index, :show]
    resources :cycles, only: [:index, :show]
    resources :bakers, only: [:index, :show]
  end
end
