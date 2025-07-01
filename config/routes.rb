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
  get "/map-demo", to: "public#map_demo", as: :map_demo

  get "/privacy-policy", to: "public#privacy_policy", as: :privacy_policy

  # Search functionality
  get "/search", to: "search#index", as: :search

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
  get "/user/applications", to: "users#applications", as: :user_applications
  post "/user/recruitment/:recruitment_id/apply", to: "users#apply_to_recruitment", as: :user_apply_to_recruitment
  patch "/user/application/:application_id/withdraw", to: "users#withdraw_application", as: :user_withdraw_application
  
  # Onboarding routes
  get "/user/onboarding", to: "users#onboarding", as: :user_onboarding
  patch "/user/onboarding", to: "users#onboarding_update", as: :user_onboarding_update
  get "/user/onboarding/back", to: "users#onboarding_back", as: :user_onboarding_back

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

  # New recruiter namespace routes
  namespace :recruiter do
    # Dashboard
    get "/dashboard", to: "dashboard#index", as: :dashboard
    
    # Companies management
    get "/companies", to: "companies#index", as: :companies
    get "/company/:id", to: "companies#show", as: :company
    get "/company/:id/edit", to: "companies#edit", as: :edit_company
    patch "/company/:id", to: "companies#update", as: :update_company
    
    # Company recruitments
    get "/company/:id/recruitments", to: "companies#recruitments", as: :company_recruitments
    
    # Manage recruitments
    get "/recruitments", to: "recruitments#index", as: :recruitments
    get "/recruitments/new", to: "recruitments#new", as: :new_recruitment
    post "/recruitments", to: "recruitments#create", as: :create_recruitment
    get "/recruitments/:id", to: "recruitments#show", as: :recruitment
    get "/recruitments/:id/edit", to: "recruitments#edit", as: :edit_recruitment
    patch "/recruitments/:id", to: "recruitments#update", as: :update_recruitment
    delete "/recruitments/:id", to: "recruitments#destroy", as: :destroy_recruitment
    
    # Recruitment applications
    get "/recruitments/:id/applications", to: "recruitments#applications", as: :recruitment_applications
    
    # All applications across companies
    get "/applications", to: "applications#index", as: :applications
    patch "/applications/:id/status", to: "applications#update_status", as: :update_application_status
    
    # Analytics
    get "/analytics", to: "analytics#index", as: :analytics
  end

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

  # Control Unit Courses Management
  namespace :control_unit do
    resources :courses do
      member do
        get :applications
        patch 'applications/:application_id/status', to: 'courses#update_application_status', as: :update_application_status
        get 'applications/:application_id/review', to: 'courses#review_application', as: :review_application
      end
    end
  end

  # Public Courses
  resources :courses, only: [:index, :show] do
    member do
      post :apply
    end
    collection do
      get :search
      get :my_applications
      patch 'applications/:id/withdraw', to: 'courses#withdraw_application', as: :withdraw_application
    end
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
end
