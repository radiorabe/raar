Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    resources :shows, only: [:index, :show] do
      resources :broadcasts, only: :index
    end

    resources :broadcasts, only: [:index, :show] do
      resources :audio_files, only: :index
    end

    get 'audio_files/:year/:month/:day/:hour:min(:sec)_:playback_format.:format',
        to: 'audio_files#show',
        as: :audio_file,
        year: /\d{4}/,
        month: /\d{2}/,
        day: /\d{2}/,
        hour: /\d{2}/,
        min: /\d{2}/,
        sec: /\d{2}/

    resources :users
  end

end
