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

  def get_data(article, options = {})

    # Check that article has DOI
    return { events: [], event_count: nil } if article.doi.blank?

    data = get_xml_request(article)

    query_url = get_query_url(article)
    result = post_xml(query_url, options.merge(data: data))

    return { events: [], event_count: nil } if result.nil?

    # Check that WOS has returned the correct status message,
    # otherwise report an error
    status = result.at_xpath('//xmlns:fn[@name="LinksAMR.retrieve"]')
    status = status.nil? ? '' : status['rc']

    if status.casecmp('OK') != 0
      if status == 'Server.authentication'
        class_name = 'Net::HTTPUnauthorized'
        status_code = 401
      else
        class_name = 'Net::HTTPNotFound'
        status_code = 404
      end
      error = result.at_xpath('//xmlns:error')
      error = error.nil? ? 'an error occured' : error.content
      message = "Web of Science error #{status}: '#{error}' for article #{article.doi}"
      Alert.create(exception: '',
                   message: message,
                   class_name: class_name,
                   status: status_code,
                   source_id: id)
      return { events: [], event_count: nil }
    end

    cite_count = result.at_xpath('//xmlns:map[@name="WOS"]/xmlns:val[@name="timesCited"]')
    cite_count = cite_count.nil? ? 0 : cite_count.content.to_i
    event_metrics = { pdf: nil,
                      html: nil,
                      shares: nil,
                      groups: nil,
                      comments: nil,
                      likes: nil,
                      citations: cite_count,
                      total: cite_count }

    if cite_count > 0
      events_url = result.at_xpath('//xmlns:map[@name="WOS"]/xmlns:val[@name="citingArticlesURL"]')
      events_url = events_url.content unless events_url.nil?

      { events: cite_count,
        events_url: events_url,
        event_count: cite_count,
        attachment: { filename: 'events.xml', content_type: 'text/xml', data: result.to_s }
      }
    else
      { events: 0, event_count: 0, event_metrics: event_metrics, events_url: nil, attachment: nil }
    end
  end

  def get_query_url(article)
    config.url
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

  def get_config_fields
    [{ field_name: 'url', field_type: 'text_area', size: '90x2' }]
  end
end