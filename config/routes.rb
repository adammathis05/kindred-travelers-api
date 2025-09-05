Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'api/v1/registrations',
    sessions: 'api/v1/sessions'
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/signup', to: 'registrations#create'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      get '/me', to: 'users#show'

      # User routes
      resources :users, only: [:show, :update] do
        member do
          get :dashboard
          get :expenses_summary
        end
      end

      # Tribe routes
      resources :tribes, only: [:show, :update] do
        member do
          get :dashboard
          get :members
          get :budget_summary
          get :expense_breakdown
          post :join_tribe
        end
        
        # Nested resources for tribe-specific data
        resources :reservations, except: [:show] do
          member do
            patch :update_status
          end
        end
        
        resources :vision_board_items, path: 'vision_board', except: [:show] do
          member do
            patch :toggle_achieved
          end
        end
      end

      # Individual resource routes (for showing specific items)
      resources :reservations, only: [:show]
      resources :vision_board_items, only: [:show], path: 'vision_board'

      # Utility routes
      get '/tribes/:id/invite_info', to: 'tribes#invite_info'
      post '/join_with_code', to: 'tribes#join_with_code'
      
      # Dashboard and analytics
      get '/dashboard', to: 'dashboard#index'
      get '/analytics', to: 'analytics#index'
    end
  end

  # Catch all route for React Router (if serving React from Rails)
  # get '*path', to: 'application#fallback_index_html', constraints: ->(request) do
  #   !request.xhr? && request.format.html?
  # end
end
