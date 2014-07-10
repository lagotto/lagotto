Alm::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }

  root :to => "docs#index"

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :articles, :constraints => { :id => /.+?/, :format => /html/}

  resources :sources
  resources :users
  resources :status, only: [:index]
  resources :docs, :only => [:index, :show], :constraints => { :id => /[0-z\-\.\(\)]+/ }

  match "oembed" => "oembed#show"

  namespace :admin do
    resources :articles, :constraints => { :id => /.+?/, :format => /html|js/ }
    resources :sources
    resources :errors
    resources :alerts
    resources :api_requests
    resources :users
    resources :filters
  end

  namespace :api do
    namespace :v3 do
      resources :articles, :constraints => { :id => /.+?/, :format=> false }, only: [:index, :show]
      resources :sources, :constraints => { :format=> false }, only: [:index, :show]
      resources :status, :constraints => { :format=> false }, only: [:index]
      resources :api_requests, :constraints => { :format=> false }, only: [:index]
    end

    namespace :v4 do
      resources :articles, :constraints => { :id => /.+?/, :format=> false }
    end

    namespace :v5 do
      resources :articles, :constraints => { :id => /.+?/, :format=> false }, only: [:index]
      resources :sources, :constraints => { :format=> false }, only: [:index, :show]
      resources :status, :constraints => { :format=> false }, only: [:index]
      resources :api_requests, :constraints => { :format=> false }, only: [:index]
    end
  end
end
