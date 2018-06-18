Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'apidocs#index'

  resources :shows, only: [:index, :show] do
    get 'podcasts/:playback_format.:format', to: 'podcasts#show'
  end

  resources :broadcasts, only: [:show, :update] do
    resources :audio_files, only: :index
  end

  constraints(year: /\d{4}/, month: /\d{2}/, day: /\d{2}/,
              hour: /\d{2}/, min: /\d{2}/, sec: /\d{2}/) do
    get '(/shows/:show_id)/broadcasts(/:year(/:month(/:day(/:hour(:min(:sec))))))',
        to: 'broadcasts#index',
        as: :broadcasts

    get 'audio_files/:year/:month/:day/:hour:min(:sec)_:playback_format.:format',
        to: 'audio_files#show',
        as: :audio_file
  end

  get 'login', to: 'login#show'
  post 'login', to: 'login#create'
  patch 'login', to: 'login#update'

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

    resources :users
  end

end
