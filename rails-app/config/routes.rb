Rails.application.routes.draw do
  get "/", to: proc { [200, {}, ["GotchiForge API"]] }
  namespace :api do
    post "users", to: "users#create"
    get "users/find", to: "users#find"
    get "users/:id/wallets", to: "wallets#index"
    get "users/:id/gotchis", to: "aavegotchis#index"
    post "summon", to: "aavegotchis#summon"
    get "gotchis/:id", to: "aavegotchis#show"
    post "stake/:id", to: "aavegotchis#stake"
    post "unstake/:id", to: "aavegotchis#unstake"
    post "claim/:id", to: "aavegotchis#claim"
    post "equip/:id", to: "aavegotchis#equip"

    get "orderbook", to: "orderbook#show"
    resources :orders, only: [:index, :create, :destroy]
    get "trades", to: "trades#index"

    # Internal: for Go processor
    get "internal/staked_gotchis", to: "internal#staked_gotchis"
    post "internal/apply_yield", to: "internal#apply_yield"
  end
end
