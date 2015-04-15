require 'sidekiq/web'

Lagotto::Application.routes.draw do
  # mount EmberCLI::Engine => "ember-tests" if Rails.env.development?

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  #root :to => "ember#index"
  #get '/docs/*path' => 'ember#index'
  root :to => "docs#index"

  resources :alerts
  resources :api_requests
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :filters
  resources :publishers, param: :member_id
  resources :related_works
  resources :sources, param: :name do
    resources :publisher_options, only: [:show, :edit, :update]
  end
  resources :status, :only => [:index]
  resources :users

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :works, constraints: { :id => /.+?/, :format => /html|js|rss/ }

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
      concern :workable do
        resources :works, constraints: { :id => /.+?/ }
      end

      concern :eventable do
        resources :events
      end

      resources :alerts
      resources :api_requests, only: [:index]
      resources :docs, only: [:index, :show]
      resources :events
      resources :groups, only: [:index, :show]
      resources :publishers, concerns: [:workable, :eventable]
      resources :related_works
      resources :relation_types, only: [:index, :show]
      resources :sources, concerns: [:workable, :eventable] do
        resources :months
      end
      resources :status, only: [:index]
      resources :work_types, only: [:index, :show]
      resources :works, constraints: { :id => /.+?/, :format=> false } do
        resources :related_works
        resources :events
      end
    end
  end

  # rescue routing errors
  match "*path", to: "alerts#routing_error", via: [:get, :post]
end
