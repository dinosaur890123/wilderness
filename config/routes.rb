Rails.application.routes.draw do
  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  root "landing#index"

  get "docs", to: "docs#index"
  get "test", to: "landing#test" if Rails.env.development?

  get "auth/:provider/callback", to: "session#create"
  get "auth/failure", to: "session#failure"
  delete "logout", to: "session#destroy"

  get "dashboard", to: "dashboard#index"
  get "camp", to: "dashboard#index", as: :camp
  get "shop", to: "shop#index"
  patch "shop/region", to: "shop#region", as: :shop_region
  get "ranger", to: "ranger#index"
  get "hackatime/connect", to: "hackatime_connections#create"
  get "hackatime/callback", to: "hackatime_connections#callback"
  delete "hackatime/disconnect", to: "hackatime_connections#destroy"


  resources :projects, except: [ :show, :destroy ] do
    post :sync, on: :collection
    post :ship, on: :member
  end

  namespace :admin do
    root to: "overview#index"
    get "users", to: "users#index"
    get "users/:id", to: "users#show", as: :user
    patch "users/:id", to: "users#update"
    post "users/:user_id/logs", to: "logs#create", as: :user_logs
    get "audit", to: "audit#index"
    get "projects", to: "projects#index"
    get "shop", to: "shop#index"
    post "shop", to: "shop#create"
    patch "shop/:id", to: "shop#update", as: :shop_item
    delete "shop/:id", to: "shop#destroy", as: :remove_shop_item
    get "flags", to: "flags#index"
    patch "flags/:name", to: "flags#update", as: :flag
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  mount Flipper::UI.app(Flipper) => "/flipper" if Rails.env.development?
end
