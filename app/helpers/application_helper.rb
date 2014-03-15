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
require 'rouge'

module ApplicationHelper
  def login_link
    s = form_tag '/users/auth/persona/callback', :id => 'persona_form', :class => "navbar-form" do
      p = hidden_field_tag('assertion')
      p << button_tag('Sign In with Persona', :id => 'sign_in', :class => 'btn btn-link persona')
      p
    end
    s.html_safe
  end

  def markdown(text)
    text = GitHub::Markdown.render_gfm(text)
    syntax_highlighter(text).html_safe
  end

  def syntax_highlighter(html)
    formatter = Rouge::Formatters::HTML.new(:css_class => 'hll')
    lexer = Rouge::Lexers::Shell.new

    doc = Nokogiri::HTML(html)
    doc.search("//pre").each { |pre| pre.replace formatter.format(lexer.lex(pre.text)) }
    doc.to_s
  end

  def state_label(state)
    if state == "working"
      '<span class="label label-success">working</span>'
    elsif state == "inactive"
      '<span class="label label-info">inactive</span>'
    elsif state == "disabled"
      '<span class="label label-warning">disabled</span>'
    elsif state == "available"
      '<span class="label label-primary">available</span>'
    elsif state == "retired"
      '<span class="label label-default">retired</span>'
    else
      state
    end
  end

  def number_hiding_zero(number)
    (number > 0 ? number : "")
  end

  def alerts
    %w(Net::HTTPUnauthorized ActionDispatch::RemoteIp::IpSpoofAttackError Net::HTTPRequestTimeOut Delayed::WorkerTimeout Net::HTTPConflict Net::HTTPServiceUnavailable TooManyErrorsBySourceError SourceInactiveError EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError ArticleNotUpdatedError SourceNotUpdatedError CitationMilestoneAlert)
  end

  def article_statistics_report_path
    path = "/files/alm_report.zip"
    if File.exist?("#{Rails.root}/public#{path}")
      path
    else
      nil
    end
  end

  def date_format(article)
    if article.day
      :long
    elsif article.month
      :month
    else
      :year
    end
  end

  def description_with_link(report)
    if report.name == 'article_statistics_report' && article_statistics_report_path
      h(report.description) + link_to("Download", article_statistics_report_path, :class => 'pull-right')
    else
      h(report.description)
    end
  end

  def article_alerts
    %w(EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError ArticleNotUpdatedError CitationMilestoneAlert)
  end

  def documents
    %w(Home Installation Setup Sources API Rake Alerts FAQ Roadmap Contributors)
  end

  def roles
    %w(user staff admin)
  end
end