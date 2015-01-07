require 'sidekiq/web'

Lagotto::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }

  root :to => "docs#index"

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :works, constraints: { :id => /.+?/, :format => /html|js/ }
  resources :sources, param: :name do
    resources :publisher_options, only: [:show, :edit, :update]
  end
  resources :users
  resources :publishers, param: :member_id
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :alerts
  resources :api_requests
  resources :filters

  get "status", to: "status#show"
  get "heartbeat", to: "heartbeat#show", defaults: { format: "json" }
  get "oembed", to: "oembed#show"

  get "/files/alm_report.zip", to: redirect("/files/alm_report.zip")

  namespace :api, defaults: { format: "json" } do
    namespace :v3 do
      resources :works, path: "articles", constraints: { :id => /.+?/, :format=> false }, only: [:index, :show]
    end

    namespace :v4 do
      resources :alerts, :constraints => { :format=> false }
      resources :works, path: "articles", constraints: { :id => /.+?/, :format=> false }
    end

    namespace :v5 do
      resources :works, path: "articles", constraints: { :id => /.+?/ }, only: [:index]
      resources :sources, only: [:index, :show], param: :name
      get "status", to: "status#show"
      resources :api_requests, only: [:index]
      resources :publishers, only: [:index], param: :member_id
    end
  end

  # redirect from old admin namespace
  get "/admin/:name", to: redirect("/%{name}")
  get "/admin/", to: redirect("/status")

  # rescue routing errors
  match "*path", to: "alerts#routing_error", via: [:get, :post]
end
