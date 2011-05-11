# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2011 by Public Library of Science, a non-profit corporation
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

include SourceHelper

namespace :pmc do
  RAILS_DEFAULT_LOGGER = ActiveSupport::BufferedLogger.new "#{RAILS_ROOT}/log/#{RAILS_ENV}_pmc_data_pull_rake.log"

  task :update => :environment do
    
    # looking at last month's information
    if ENV["MONTH"] && ENV["YEAR"]
      month = ENV["MONTH"]
      year = ENV["YEAR"]
    else
      time = Time.new
      month = time.month - 1
      year = time.year
    end

    Rails.logger.info "Getting PMC information for #{month} #{year}"
    
    source = Source.find_by_type("Pmc")
    config = YAML.parse(source.misc)
    filepath = config["filepath"]
    filepath = filepath.transform

    mainDocument = XML::Document.new()
    mainDocument.root = XML::Node.new('articles')
    mainDocument.root.attributes['month'] = month.to_s
    mainDocument.root.attributes['year'] = year.to_s

    journals = ["plosbiol", "plosmed", "ploscomp", "plosgen", "plospath", "plosone", "plosntds"];

    journals.each do |journal|
      Rails.logger.info "Getting PMC information for journal #{journal}"

      url = "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=#{year}&month=#{month}&jrid=#{journal}&user=plospubs&password=er56nm"
      
      get_xml(url) do |document|
        document.find("/pmc-web-stat/response").each do | response |
          attributes = response.attributes
          if (attributes['status'] <=> "0")
            # good
            document.find("//article").each do |article|
              article2 = mainDocument.import(article)
              mainDocument.root << article2
            end
          else
            # bad
            Rails.logger.error "Bad status from PMC"
          end
        end
      end
    end

    mainDocument.save(filepath)

    # keep a history of the files
    index = filepath.rindex('.')
    filepath = filepath[0..index-1] + "_#{month}_#{year}.xml"
    mainDocument.save(filepath)

  end

  task :update_all => :environment do
    # this code is meant to run just once, when PMC is added as a source
    # should be removed after the deployment.
    
    months = (1..12).to_a
    year = 2010
        
    months.each do | month |
      call_rake "pmc:update", {:MONTH => month, :YEAR => year}
      call_rake "db:update", {:LAZY => 0, :SOURCE => "Pmc", :LIMIT => 2}
    end

    time = Time.new
    months = (1..time.month-1).to_a
    year = 2011

    months.each do | month |
      call_rake "pmc:update", {:MONTH => month, :YEAR => year}
      call_rake "db:update", {:LAZY => 0, :SOURCE => "Pmc", :LIMIT => 2}
    end
  end

  # this is only used by update_all task, remove it when we remove update_all task
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace"
  end
  
end