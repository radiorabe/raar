Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'apidocs#index'

  resources :shows, only: [:index, :show]

  resources :broadcasts, only: [] do
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
  put 'login', to: 'login#update'

  namespace :admin do
    resources :users

    resources :audio_encodings, only: :index

    resources :profiles do
      resources :archive_formats do
        resources :downgrade_actions
      end
    end

    resources :playback_formats

    resources :shows do
      post 'merge/:target_id', to: 'shows/merge#create', on: :member
    end
  end

end
