# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
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

class User < ActiveRecord::Base
  
  before_save :ensure_authentication_token
  
  devise :rememberable, :trackable, :token_authenticatable, :omniauthable, :omniauth_providers => [:github]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :provider, :uid, :name, :email, :role, :remember_me 
  
  default_scope order("sign_in_count DESC, updated_at DESC")

  scope :query, lambda { |query| where("name like ? OR username like ? OR authentication_token like ?", "%#{query}%", "%#{query}%", "%#{query}%") }
  
  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      # The first user we create has an admin role
      role = User.count > 0 ? "user" : "admin"
      user = User.create(:username => auth.info.nickname,
                         :provider => auth.provider,
                         :uid => auth.uid,
                         :name => auth.extra.raw_info.name,
                         :email => auth.info.email,
                         :role => role)
    end
    user
  end
end