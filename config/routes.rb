Rails.application.routes.draw do
  root "dashboard#index"

  resources :stays do
    resources :pois, only: [:index, :create, :update, :destroy]
    resources :transit_routes, only: [:index, :create]
  end

  get "map", to: "stays#index", as: :map
  get "timeline", to: "timeline#index", as: :timeline

  # API endpoints for map
  get "api/stays", to: "stays#map_data", as: :api_stays
  get "api/stays/:id/pois", to: "pois#fetch", as: :api_stay_pois
  get "api/stays/:id/transit_routes", to: "transit_routes#fetch", as: :api_stay_transit_routes
  get "api/pois/search", to: "pois#search", as: :api_pois_search

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
