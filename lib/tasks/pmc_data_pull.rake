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

require "source_helper"
require 'date'

include SourceHelper

namespace :pmc do

  task :update, [:month,:year] => :environment do |t, args|

    # looking at last month's information
    if args.month && args.year
      month = args.month.to_i
      year = args.year.to_i
      begin
        Date.new(year, month, 1)
      rescue
        puts "Month and/or year values were invalid.  Please try again."
        exit
      end
    else
      date = Date.today
      date = date.prev_month

      month = date.month
      year = date.year
    end

    Rails.logger.info "Getting PMC information for #{month} #{year}"
    puts "Getting PMC information for #{month} #{year}"
    
    # Assume that the PMC source does exist
    source = Source.find_by_name("pmc")

    filepath = source.filepath
    service_url = source.url

    if filepath.nil? || service_url.nil?
      Rails.logger.error("filepath or url is missing")
      exit
    end

    if not filepath.end_with?("/")
      filepath = filepath  + "/"
    end

    puts "Filepath: " + filepath
    puts "Service URL: " + service_url

    journals = ["plosbiol", "plosmed", "ploscomp", "plosgen", "plospath", "plosone", "plosntd", "plosct", "ploscurrents"];

    journals.each do |journal|
      Rails.logger.info "Getting PMC information for journal #{journal}"

      url = "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=#{year}&month=#{month}&jrid=#{journal}&user=plospubs&password=er56nm"

      get_xml(url) do | document |
        document.save("#{filepath}pmcstat_#{journal}_#{month}_#{year}.xml")

        document.find("/pmc-web-stat/response").each do | response |
          attributes = response.attributes

          if (attributes['status'] <=> "0")
            # good
            Rails.logger.info "Start processing #{journal} #{month} #{year}"
            puts "Start processing #{journal} #{month} #{year}"

            process_doc(document, service_url)
          else
            Rails.logger.error "Bad status from PMC #{attributes['status']}"
            puts "Bad status from PMC #{attributes['status']}"
          end
        end
      end

    end
  end

  # this is only used by update_all task, remove it when we remove update_all task
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace"
  end


  def process_doc(document, service_url)

    request_elem = document.find_first("request")
    attributes = request_elem.attributes
    year = attributes['year']
    month = attributes['month']

    # go through all the articles in the xml document
    document.find("//article").each do | article |

      # get the doi
      metadata = article.find_first("meta-data");
      attributes = metadata.attributes
      doi = attributes['doi']

      # create the url to get existing information about the given article
      url = service_url % { :doi => CGI.escape(doi) }

      stat_data = nil
      views = []

      begin
        # try to get the existing information about the given article
        stat_data = get_json(url)
        views = stat_data['views']

        # remove the entry we are trying to update
        views.delete_if { | view | view['month'].eql?(month) && view['year'].eql?(year) }

      rescue

      end

      view = {}

      usage = article.find_first("usage")
      attributes = usage.attributes
      attributes.each { | attribute | view[attribute.name] = attribute.value }

      view['year'] = year
      view['month'] = month

      views << view

      new_data = nil

      if stat_data.nil?
        # if there isn't an existing data
        new_data = ActiveSupport::JSON.encode(views)
        new_data = "{\"views\":#{new_data}}"
      else
        # append the new data to the existing data
        stat_data['views'] = views
        new_data = ActiveSupport::JSON.encode(stat_data)
      end

      begin
        response = put(url, new_data)
      rescue => e
        Rails.logger.error "Error #{url} #{new_data} (#{e.class.name}: #{e.message})"
        puts "Error #{url} #{new_data} (#{e.class.name}: #{e.message})"
      end

    end
  end

  def put(url, json)
    
    url = URI.parse(url)
    
    req = Net::HTTP::Put.new(url.path)
    req["content-type"] = "application/json"
    req.body = json

    res = Net::HTTP.start(url.host, url.port) { | http | http.request(req) }
    
    unless res.kind_of?(Net::HTTPSuccess)
      e = RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
      raise e
    end
    
    res
  end

end
