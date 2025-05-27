Rails.application.routes.draw do

    authenticated :control_unit do
    #   root to: "control_unit/pages#home", as: :authenticated_root

    #   devise_scope :control_unit do
    #     get "settings", to: "control_unit/settings#index", as: :settings
    #     get "settings/profile", to: "control_unit/settings#edit_profile", as: :edit_profile
    #     put "settings/profile", to: "control_unit/settings#update_profile", as: :update_profile
    #     get "settings/password", to: "control_unit/settings#edit_password", as: :edit_profile_password
    #     put "settings/password", to: "control_unit/settings#update_password", as: :update_profile_password
    #     get "settings/about", to: "control_unit/settings#edit_about", as: :edit_profile_about
    #     put "settings/about", to: "control_unit/settings#update_about", as: :update_profile_about
    #   end


    # sidekiq web UI
    require "sidekiq/web"
    mount Sidekiq::Web => "control_unit/sidekiq", as: :sidekiq

  end



  root "public#home"
  get "/about"=> "public#about"
  get "/contact"=> "public#contact"


  devise_for :users,
              path: "user",
              path_names:
              {
                sign_in: "login",
                sign_out: "logout",
                sign_up: "register",
                # confirmation: 'verification',
                registration: "account",
                cancel: "close"
              },
              controllers:
              {
                sessions: "user/sessions",
                registrations: "user/registrations",
                passwords: "user/passwords",
                confirmations: "user/confirmations"
                # unlocks: "user/unlocks",
                # omniauth: "user/omniauth_callbacks"
              }
    get "/user/", to: "users#index", as: :user_index

  devise_for :control_units,
              path: "control_unit",
              path_names:
              {
                sign_in: "login",
                sign_out: "logout",
                sign_up: "register",
                # confirmation: 'verification',
                registration: "account",
                cancel: "close"
              },
              controllers:
              {
                sessions: "control_unit/sessions",
                registrations: "control_unit/registrations",
                passwords: "control_unit/passwords",
                confirmations: "control_unit/confirmations"
                # unlocks: "control_unit/unlocks",
                # omniauth: "control_unit/omniauth_callbacks"
              }

    get "/control_unit/", to: "control_units#index", as: :control_unit_index

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
