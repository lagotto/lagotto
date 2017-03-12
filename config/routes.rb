Lagotto::Application.routes.draw do
  root :to => 'index#index'

  resources :index, only: [:index]
  resources :heartbeat, only: [:index]

  scope module: :api, defaults: { format: "json" } do
    resources :events
    resources :sources
    resources :status
    resources :works, constraints: { :id => /.+?/, :format=> false }
  end

  # rescue routing errors
  match "*path", to: "index#routing_error", via: :all
end
