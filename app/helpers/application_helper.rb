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

require 'github/markdown'

module ApplicationHelper
  def link_to_setup_or_login
    if APP_CONFIG['cas_url']
      link_to "Sign In", user_omniauth_authorize_path(:cas), :id => "sign_in"
    # elsif APP_CONFIG['github_client_id']
    #   link_to "Sign In with Github", user_omniauth_authorize_path(:github), :id => "sign_in"
    # elsif APP_CONFIG['persona']
    #   s = form_tag '/users/auth/persona/callback', :id => 'persona_form', :class => "navbar-form" do
    #     p = hidden_field_tag('assertion')
    #     p << button_tag('Sign In with Persona', :id => 'sign_in', :class => 'btn btn-link btn-form')
    #     p
    #   end
    #   s.html_safe
    elsif User.count > 0
      link_to "Sign In", new_user_session_path, :class => current_page?(new_user_session_path) ? 'current' : '', :id => "sign_in"
    else
      link_to 'Sign Up', new_user_registration_path, :class => current_page?(new_user_registration_path) ? 'current' : '', :id => "sign_in"
    end
  end

  def markdown(text)
    GitHub::Markdown.render_gfm(text).html_safe
  end

  def state_label(state)
    if state == "inactive"
      '<span class="label label-info">inactive</span>'
    elsif state == "disabled"
      '<span class="label label-important">disabled</span>'
    else
      state
    end
  end

  def number_not_showing_zero(number, options = {})
    if number.nil? or number.to_i == 0
      ""
    elsif options[:precision]
      number_with_precision(number, precision: options[:precision])
    else
      number_with_delimiter(number.to_i)
    end
  end

  def sources
    Source.order("group_id, display_name")
  end

  def alerts
    %w(Net::HTTPUnauthorized ActionDispatch::RemoteIp::IpSpoofAttackError Net::HTTPRequestTimeOut Delayed::WorkerTimeout Net::HTTPConflict Net::HTTPServiceUnavailable TooManyErrorsBySourceError SourceInactiveError EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError ArticleNotUpdatedError SourceNotUpdatedError CitationMilestoneAlert)
  end

  def article_alerts
    %w(EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError ArticleNotUpdatedError CitationMilestoneAlert)
  end

  def documents
    %w(Home Installation Setup Sources API Rake Alerts FAQ Roadmap Past-Contributors)
  end

  def roles
    %w(user staff admin)
  end
end
