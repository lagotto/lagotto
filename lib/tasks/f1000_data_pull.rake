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

namespace :f1000 do
  
  desc "Bulk-import F1000Prime data"
  task :update => :environment do 
    source = Source.find_by_name("f1000")
    if source.nil?
      message = "Source \"f1000\" is missing"
      ErrorMessage.create(:exception => "", :class_name => "NoMethodError",
                          :message => message)
      puts "Error: #{message}"
      exit
    end

    if source.get_feed.nil?
      message "An error occured while getting the f1000 feed"
      Rails.logger.info message
      puts message
    else
      message = "The f1000 feed was successfully updated."
      Rails.logger.info message
      puts message
    end
  end
end
