Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root "dashboard#index"

  # API v1 namespace for mobile app
  namespace :api do
    namespace :v1 do
      # Auth is handled by devise-api routes at /users/tokens/*

      # User Profile
      get "profile", to: "users#show"
      patch "profile", to: "users#update"
      patch "profile/password", to: "users#update_password"
      delete "profile", to: "users#destroy"

      # Stays
      resources :stays do
        member do
          get :weather
          get :gallery
          get :highlights
        end
        resources :pois, only: [ :index ] do
          collection do
            post :fetch
            post :toggle_favorite
          end
        end
        resources :transit_routes, only: [ :index ] do
          collection do
            post :fetch
          end
        end
        resources :bucket_list_items, only: [ :index, :create ]
        resources :comments, only: [ :index, :create ]
        resources :collaborations, only: [ :index, :create, :destroy ] do
          collection do
            delete :leave
          end
        end
      end

      # Standalone resources
      resources :bucket_list_items, only: [ :update, :destroy ] do
        member do
          patch :toggle
          post :rate
        end
      end
      resources :comments, only: [ :update, :destroy ]
      resources :places, only: [ :show ] do
        resources :comments, only: [ :index, :create ], controller: "place_comments"
      end

      # Map endpoints
      get "map/stays", to: "map#stays"
      get "map/pois/search", to: "map#pois_search"
      get "map/bucket_list_items", to: "map#bucket_list_items"

      # Notifications
      resources :notifications, only: [ :index ] do
        member do
          patch :read
        end
        collection do
          post :mark_all_read
        end
      end

      # Invite acceptance
      post "invites/:token/accept", to: "invites#accept"

      # Destinations
      get "destinations", to: "destinations#index"
    end
  end

  resources :notifications, only: [ :index ] do
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end

  resources :places, only: [ :show ] do
    member do
      get :place_search
    end
    resources :comments, only: [ :create, :edit, :update, :destroy ], controller: "place_comments"
  end

  resources :stays do
    member do
      get :weather
      get :edit_notes
      patch :update_notes
      get :place_search
    end
    resources :pois, only: [ :index, :create, :update, :destroy ] do
      collection do
        post :toggle_favorite
      end
    end
    resources :transit_routes, only: [ :index, :create ]
    resources :bucket_list_items, only: [ :create, :edit, :update, :destroy ] do
      member do
        patch :toggle
      end
      resource :rating, only: [ :create, :destroy ], controller: "bucket_list_item_ratings"
    end
    resources :comments, only: [ :create, :edit, :update, :destroy ]
    resources :collaborations, only: [ :index, :create, :destroy ], controller: "stay_collaborations" do
      collection do
        delete :leave
      end
    end
    resource :gallery, only: [ :show ], path: "explore" do
      post :add_to_bucket_list
    end
    resource :highlights, only: [ :show ]
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
  get "api/bucket_list_items", to: "bucket_list_items#map_index", as: :api_bucket_list_items

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
