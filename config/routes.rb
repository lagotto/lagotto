# $HeadURL: $
# $Id: $
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ActionController::Routing::Routes.draw do |map|
  map.resources :articles, :requirements => { :id => /.+?/ }
  map.resources :sources
  map.resources :groups

  #We originally wanted to make the "." part of the connect statement and not the regex. 
  #But we encountered some weirdness, and this seems to work.
  map.connect '/group/articles/:id:format',
    :controller => 'groups',
    :action     => 'groupArticleSummaries',
    :requirements => { :id => /.+/, :format => /.(json|xml|csv)/ }

  map.connect '/group/articles/:id',
    :controller => 'groups',
    :action     => 'groupArticleSummaries',
    :requirements => { :id => /.+?/ }

  #Maps .xml/.csv/.json requests to this function when doi is passed as a parameter
  map.connect '/group/articles.:format',
    :controller => 'groups',
    :action     => 'groupArticleSummaries',
    :requirements => { :format => /(json|xml|csv)/ }

  map.root :controller => "articles"

  map.docs '/docs/:action', :controller => "docs"
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users
  map.resource :session

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # BJS: Removed; all the routes we need are at the top.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
