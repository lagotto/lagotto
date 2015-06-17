require 'sidekiq/web'

Lagotto::Application.routes.draw do
  # mount EmberCLI::Engine => "ember-tests" if Rails.env.development?

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  #root :to => "ember#index"
  #get '/docs/*path' => 'ember#index'

  # simplify GET route to works
  get '/:id', to: 'works#show', constraints: { id: /(http|https):\/\/.+/, format: /html/ }
  root :to => "docs#index"

  resources :alerts
  resources :api_requests
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }
  resources :filters
  resources :publishers
  resources :references

  # use namespace for rss feeds rather than file extension
  namespace :rss, defaults: { format: "rss" } do
    resources :works, constraints: { :id => /.+/ }, only: [:show]
    resources :sources, only: [:show]
  end

  # redirect old rss routes
  get '/sources/:id.rss', to: redirect { |params, request| "/rss/sources/#{request.params[:id]}?#{request.params.to_query}" }

  resources :sources do
    resources :publisher_options, only: [:show, :edit, :update]
  end
  resources :status, :only => [:index]
  resources :users

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :works, constraints: { :id => /.+/, :format => /html|js/ }

  get "oembed", to: "oembed#show"

  get "/files/alm_report.zip", to: redirect("/files/alm_report.zip")
  get "/api", to: "api/index#index"

  namespace :api, defaults: { format: "json" } do
    namespace :v3 do
      resources :works, path: "articles", constraints: { :id => /.+?/, :format=> false }, only: [:index, :show]
    end

    namespace :v5 do
      resources :works, path: "articles", constraints: { :id => /.+?/ }, only: [:index]
      resources :sources, only: [:index, :show]
      resources :status, only: [:index]
      resources :api_requests, only: [:index]
      resources :publishers, only: [:index]
    end

    scope module: :v6, constraints: ApiConstraint.new(version: 6, default: :true) do
      concern :workable do
        resources :works, constraints: { :id => /.+?/, format: false }
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
      resources :references
      resources :relation_types, only: [:index, :show]
      resources :sources, concerns: [:workable, :eventable] do
        resources :months
      end
      resources :status, only: [:index]
      resources :work_types, only: [:index, :show]
      resources :works, constraints: { :id => /.+?/, :format=> false } do
        resources :references
        resources :versions
        resources :recommendations
        resources :events
      end
    end
  end

  # rescue routing errors
  match "*path", to: "alerts#routing_error", via: [:any]
end
