# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'apidocs#index'

  defaults format: :json do
    resources :shows, only: [:index, :show, :update]

    resources :broadcasts, only: [:show, :update] do
      resources :audio_files, only: :index
      resources :tracks, only: :index
    end

    resources :tracks, except: :index

    constraints(year: /\d{4}/, month: /\d{2}/, day: /\d{2}/,
                hour: /\d{2}/, min: /\d{2}/, sec: /\d{2}/,
                time: /(\d{2})(\d{2})?(\d{2})?/) do
      # Does not work anymore with rails 7:
      # get '(/shows/:show_id)/broadcasts(/:year(/:month(/:day(/:hour(:min(:sec))))))',
      get '(/shows/:show_id)/broadcasts(/:year(/:month(/:day(/:time))))',
          to: 'broadcasts#index',
          as: :broadcasts

      get 'audio_files/:year/:month/:day/:hour:min(:sec)_:playback_format.:format',
          to: 'audio_files#show',
          as: :audio_file

      get '(/shows/:show_id)/tracks(/:year(/:month(/:day(/:time))))',
          to: 'tracks#index'
    end

    get 'login', to: 'login#show'
    post 'login', to: 'login#create'
    patch 'login', to: 'login#update'
    # duplicate entry to allow different server config for checking sso authentication
    get 'sso', to: 'login#show'

    get 'status', to: 'status#show'

    namespace :admin do
      resources :access_codes

      resources :audio_encodings, only: :index

      resources :playback_formats

      resources :profiles do
        resources :archive_formats do
          resources :downgrade_actions
        end
      end

      resources :shows do
        post 'merge/:target_id', to: 'shows/merge#create', on: :member
      end

      get 'stats/:year(/:month)', to: 'stats#index'

      resources :users
    end
  end
end
