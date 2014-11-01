Lagotto::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }

  root :to => "docs#index"

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :articles, :constraints => { :id => /.+?/, :format => /html|js/ }
  resources :sources do
    resources :publisher_options, only: [:show, :edit, :update]
  end
  resources :users
  resources :publishers
  resources :status, only: [:index]
  resources :heartbeat, only: [:index]
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :alerts
  resources :api_requests
  resources :filters

  get "oembed" => "oembed#show"
  get "/files/alm_report.zip", to: redirect("/files/alm_report.zip")

  namespace :api do
    namespace :v3 do
      resources :articles, :constraints => { :id => /.+?/, :format=> false }, only: [:index, :show]
    end

    namespace :v4 do
      resources :alerts, :constraints => { :format=> false }
      resources :articles, :constraints => { :id => /.+?/, :format=> false }
    end

    namespace :v5 do
      resources :articles, :constraints => { :id => /.+?/, :format=> false }, only: [:index]
      resources :sources, :constraints => { :format=> false }, only: [:index, :show]
      resources :status, :constraints => { :format=> false }, only: [:index]
      resources :api_requests, :constraints => { :format=> false }, only: [:index]
      resources :publishers, :constraints => { :format=> false }, only: [:index]
    end
  end

  # redirect from old admin namespace
  get "/admin/:name", to: redirect("/%{name}")
  get "/admin/", to: redirect("/status")

  # rescue routing errors
  match "*path", to: "alerts#routing_error", via: [:get, :post]
end
