Rails.application.routes.draw do
  root "dashboard#index"

  resource :registration, only: %i[new create]
  resource :session
  resources :passwords, param: :token

  resources :projects do
    resource :report, only: [:show], module: :projects
    resources :memberships, only: %i[index create destroy], module: :projects
    resources :labels, except: [:show], module: :projects
    resources :issues do
      collection do
        patch :reorder
      end
      member do
        get :fragment
      end
      resources :comments, only: %i[create destroy]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
