# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2013 by Public Library of Science,
# a non-profit corporation http://www.plos.org/
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

class Wos < Source
  def get_query_url(article)
    return nil unless article.doi.present?

    url
  end

  def get_data(article, options={})
    query_url = get_query_url(article)
    if query_url.nil?
      { events: [], event_count: nil }
    else
      data = get_xml_request(article)
      result = get_result(query_url, options.merge(content_type: 'xml', data: data))
      result.extend Hashie::Extensions::DeepFetch
    end
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    # Check whether WOS has returned an error status message
    error_status = check_error_status(result, article)
    return { error: error_status } if error_status

    values = Array(result.deep_fetch('response', 'fn', 'map', 'map', 'map', 'val') { nil })
    event_count = values[0].to_i
    events_url = values[2]

    { events: event_count,
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def check_error_status(result, article)
    status = result.deep_fetch 'response', 'fn', 'rc'

    if status.casecmp('OK') == 0
      return false
    else
      if status == 'Server.authentication'
        class_name = 'Net::HTTPUnauthorized'
        status_code = 401
      else
        class_name = 'Net::HTTPNotFound'
        status_code = 404
      end
      error = result.deep_fetch('response', 'fn', 'error') { 'an error occured' }
      message = "Web of Science error #{status}: '#{error}' for article #{article.doi}"
      Alert.create(exception: '',
                   message: message,
                   class_name: class_name,
                   status: status_code,
                   source_id: id)
      return message
    end
  end

  def get_xml_request(article)
    xml = ::Builder::XmlMarkup.new(indent: 2)
    xml.instruct!
    xml.request(xmlns: 'http://www.isinet.com/xrpc42',
                src: "app.id=#{CONFIG[:useragent]},env.id=#{Rails.env},partner.email=#{CONFIG[:notification_email]}") do
      xml.fn(name: "LinksAMR.retrieve") do
        xml.list do
          xml.map
          xml.map do
            xml.list(name: 'WOS') do
              xml.val 'timesCited'
              xml.val 'ut'
              xml.val 'citingArticlesURL'
            end
          end
          xml.map do
            xml.map(name: 'cite_id') do
              xml.val article.doi, name: 'doi'
            end
          end
        end
      end
    end
  end

  def config_fields
    [:url]
  end
end
