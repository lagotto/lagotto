# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

module Authenticable
  extend ActiveSupport::Concern

  included do
    def default_format_json
      request.format = :json if request.format.html?
    end

    def authenticate_user_from_token!
      user_token = params[:api_key].presence
      user       = user_token && User.find_by_authentication_token(user_token.to_s)

      if user
        sign_in user, store: false
      else
        @error = "Missing or wrong API key."
        create_alert(request)
        render "error", :status => 401
      end
    end

    def authenticate_user_via_basic_authentication!
      authenticate_or_request_with_http_basic do |username, password|
        resource = User.find_by_username(username)
        if resource && resource.valid_password?(password)
          sign_in :user, resource
        else
          @error = "You are not authorized to access this page."
          create_alert(request)
          render "error", :status => 401
        end
      end
    end

    def create_alert(request)
      Alert.create(:exception => "",
                   :class_name => "Net::HTTPUnauthorized",
                   :message => @error,
                   :target_url => request.original_url,
                   :remote_ip => request.remote_ip,
                   :user_agent => request.user_agent,
                   :content_type => request.formats.first.to_s,
                   :status => 401)
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Max-Age'] = "1728000"
    end

    def cors_preflight_check
      if request.method == :options
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
        headers['Access-Control-Max-Age'] = '1728000'
        render :text => '', :content_type => 'text/plain'
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      @error = exception.message
      @article = nil
      render "error", :status => 401
    end

    rescue_from ActionController::ParameterMissing do |exception|
      @error = { exception.param => ['parameter is required'] }
      @article = nil
      render "error", :status => 422
    end

    rescue_from ActionController::UnpermittedParameters do |exception|
      @error = Hash[exception.params.map { |v| [v, ['unpermitted parameter']] }]
      @article = nil
      render "error", :status => 422
    end

    rescue_from NoMethodError do |exception|
      @error = "Undefined method."
      @article = nil
      render "error", :status => 422
    end
  end
end
