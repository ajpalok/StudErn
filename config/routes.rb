Rails.application.routes.draw do
    authenticated :control_unit do
    #   root to: "control_unit/pages#home", as: :authenticated_root

    # sidekiq web UI
    require "sidekiq/web"
    mount Sidekiq::Web => "control_unit/sidekiq", as: :sidekiq
  end



  root "public#home"
  get "/about"=> "public#about"
  get "/contact"=> "public#contact"
  post "/contact"=> "public#contact_post", as: :contact_post

  get "/privacy-policy", to: "public#privacy_policy", as: :privacy_policy

  # All Sort of recruitments
  get "/jobs/all", to: "public#jobs_all", as: :jobs_all
  get "/jobs", to: "public#jobs", as: :jobs
  get "/micro-jobs", to: "public#micro_jobs", as: :micro_jobs
  get "/internships/all", to: "public#internships_all", as: :internships_all
  get "/internships", to: "public#internships", as: :internships
  get "/micro-internships", to: "public#micro_internships", as: :micro_internships
  get "recruitment/:recruitment_id", to: "public#recruitment", as: :recruitment


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
  get "/user/profile", to: "users#profile", as: :user_profile
  get "/user/resume", to: "users#resume", as: :user_resume
  patch "/user/resume", to: "users#resume_update", as: :user_resume_update

  devise_for :recruiters,
              path: "recruiter",
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
                sessions: "recruiter/sessions",
                registrations: "recruiter/registrations",
                passwords: "recruiter/passwords",
                confirmations: "recruiter/confirmations"
                # unlocks: "recruiter/unlocks",
                # omniauth: "recruiter/omniauth_callbacks"
              }
  get "/recruiter/", to: "recruiters#index", as: :recruiter_index
  get "/recruiter/profile", to: "recruiters#profile", as: :recruiter_profile

  # recruiter account complete
  get "/recruiter/account_complete", to: "recruiters#account_complete", as: :recruiter_account_complete
  post "/recruiter/account_complete", to: "recruiters#account_complete_post", as: :recruiter_account_complete_post
  post "/recruiter/account_complete/company_create", to: "recruiters#account_complete_company_create", as: :recruiter_account_complete_company_create
  get "/recruiter/account_complete/company/:company_id", to: "recruiters#account_complete_company_join", as: :recruiter_account_complete_company_join
  post "/recruiter/account_complete/company/:company_id", to: "recruiters#account_complete_company_join_post", as: :recruiter_account_complete_company_join_post

  # recruiter recruitment publish
  get "/recruiter/recruitment-publish", to: "recruiters#recruitment_publish", as: :recruiter_recruitment_publish
  post "/recruiter/recruitment-publish", to: "recruiters#recruitment_publish_create", as: :recruiter_recruitment_publish_create
  get "/recruiter/recruitment-publish/:company_id/:recruitment_id", to: "recruiters#recruitment_publish_complete", as: :recruiter_recruitment_publish_complete
  # post "/recruiter/recruitment-publish/:company_id/:recruitment_id", to: "recruiters#recruitment_publish_complete_pay", as: :recruiter_recruitment_publish_complete_pay

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
  get "/control_unit/profile", to: "control_unit#profile", as: :control_unit_profile

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
