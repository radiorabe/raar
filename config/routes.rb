Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    resources :shows, only: [:index, :show] do
      resources :broadcasts, only: [:index, :show]
    end

    resources :users
  end
end
