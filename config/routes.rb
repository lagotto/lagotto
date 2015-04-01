require 'sidekiq/web'

Lagotto::Application.routes.draw do
  # mount EmberCLI::Engine => "ember-tests" if Rails.env.development?

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }

  #root :to => "ember#index"
  #get '/docs/*path' => 'ember#index'
  root :to => "docs#index"

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :works, constraints: { :id => /.+?/, :format => /html|js/ }
  resources :sources, param: :name do
    resources :publisher_options, only: [:show, :edit, :update]
  end
  resources :users
  resources :publishers, param: :member_id
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :alerts, param: :uuid
  resources :api_requests
  resources :filters
  resources :status, :only => [:index]

  get "heartbeat", to: "heartbeat#show", defaults: { format: "json" }
  get "oembed", to: "oembed#show"

  get "/files/alm_report.zip", to: redirect("/files/alm_report.zip")

  get "/api", to: "api/index#index"

  namespace :api, defaults: { format: "lagotto_json" } do
    namespace :v3 do
      resources :works, path: "articles", constraints: { :id => /.+?/, :format=> false }, only: [:index, :show]
    end

    namespace :v5 do
      resources :works, path: "articles", constraints: { :id => /.+?/ }, only: [:index]
      resources :sources, only: [:index, :show], param: :name
      resources :status, only: [:index]
      resources :api_requests, only: [:index]
      resources :publishers, only: [:index], param: :member_id
    end

    scope module: :v6, constraints: ApiConstraint.new(version: 6, default: :true) do
      resources :alerts, param: :uuid
      resources :api_requests, only: [:index], param: :uuid
      resources :docs, only: [:index, :show]
      resources :events, only: [:index, :show]
      resources :groups, only: [:index, :show]
      resources :metrics, only: [:index, :show]
      resources :publishers, only: [:index, :show], param: :member_id
      resources :sources, only: [:index, :show], param: :name
      resources :status, only: [:index], param: :uuid
      resources :works, constraints: { :id => /.+?/ }
    end
  end

  # rescue routing errors
  match "*path", to: "alerts#routing_error", via: [:get, :post]
end
