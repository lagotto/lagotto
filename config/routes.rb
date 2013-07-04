Alm::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations" }
  
  # devise_scope :user do
  #   get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
  #   match 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  # end
  
  root :to => "docs#show"

  # constraints is added to allow dot in the url (doi is used to show article)
  resources :articles, :constraints => { :id => /.+?/, :format => /html|json|xml|csv/}
  
  resources :sources
  resources :groups
  resources :users
  resources :docs, :only => :show, :constraints => { :id => /[0-z\-\.\(\)]+/ }
  
  match "oembed" => "oembed#show"
  
  namespace :admin do
    root :to => "index#index"
    resources :articles, :constraints => { :id => /.+?/, :format => /html|js/ }
    resources :sources
    resources :groups
    resources :delayed_jobs
    resources :errors
    resources :events
    resources :responses
    resources :error_messages
    resources :api_requests
    resources :users
  end
  
  namespace :api do
    namespace :v3 do
      root :to => "articles#index"
      resources :articles, :constraints => { :id => /.+?/, :format=> false }, only: [:index, :show]
      resources :articles, :constraints => { :id => /.+?/, :ip => /127.0.0.1/, :format=> false }
    end
  end

  match 'group/articles/:id' => 'groups#group_article_summaries', :constraints => { :id => /.+?/, :format => /html|json|xml/}

  # maps group/articles requests to group_article_summaries function when doi is passed as a parameter
  match 'group/articles' => 'groups#group_article_summaries', :constraints => { :format => /json|xml/}
end
