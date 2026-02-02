Rails.application.routes.draw do
  devise_for :users
  root "dashboard#index"

  resources :stays do
    member do
      get :weather
      get :edit_notes
      patch :update_notes
    end
    resources :pois, only: [:index, :create, :update, :destroy] do
      collection do
        get :browse
      end
    end
    resources :transit_routes, only: [:index, :create]
    resources :bucket_list_items, only: [:create, :edit, :update, :destroy] do
      member do
        patch :toggle
      end
    end
    resources :collaborations, only: [:index, :create, :destroy], controller: 'stay_collaborations' do
      collection do
        delete :leave
      end
    end
    resource :gallery, only: [:show] do
      post :refresh
    end
  end

  # Magic link for accepting collaboration invites
  get "invites/:token", to: "stay_collaborations#accept", as: :accept_invite

  get "map", to: "stays#index", as: :map
  get "timeline", to: "timeline#index", as: :timeline
  get "destinations", to: "destinations#index", as: :destinations

  # API endpoints for map
  get "api/stays", to: "stays#map_data", as: :api_stays
  get "api/stays/:id/pois", to: "pois#fetch", as: :api_stay_pois
  get "api/stays/:id/transit_routes", to: "transit_routes#fetch", as: :api_stay_transit_routes
  get "api/pois/search", to: "pois#search", as: :api_pois_search

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
