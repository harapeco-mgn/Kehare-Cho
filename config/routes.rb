Rails.application.routes.draw do
  get "how_to_use", to: "pages#how_to_use"
  get "privacy_policy", to: "pages#privacy_policy"
  get "terms", to: "pages#terms"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # CSP 違反レポート受信エンドポイント（ブラウザが自動 POST する）
  post "/csp-violation-report-endpoint", to: "csp_reports#create"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
  get "home", to: "home#index"

  # 公開タイムライン（認証不要） - resources より前に配置
  get "hare_entries/public", to: "hare_entries#public", as: :public_hare_entries

  authenticate :user do
    root "home#index", as: :authenticated_root
    resource :profile, only: [ :show, :edit, :update ]
    resource :reflection, only: [ :show ] do
      post :analyze, on: :member
    end
    resources :hare_entries
    resources :chats, only: [ :new, :create, :show ] do
      resources :messages, only: [ :create ]
    end
  end

  namespace :share do
    resources :hare_entries, only: [ :show ], param: :token
  end

  get "meal_guide", to: "meal_guide#index"

  get "calendar", to: "calendar#index"
  get "calendar/:date", to: "calendar#show", as: :calendar_date
  resources :meal_searches, only: [ :index, :new, :create ] do
    collection do
      get :eat_out_redirect
    end
  end
end
