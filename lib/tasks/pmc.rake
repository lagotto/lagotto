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

require 'date'
require 'addressable/uri'

# include HTTP request helpers
include Networkable

namespace :pmc do

  desc "Bulk-import PMC usage stats by month and journal"
  task :update, [:month,:year] => :environment do |t, args|

    source = Source.find_by_name("pmc")
    if source.nil?
      message = "Source \"pmc\" is missing"
      Alert.create(:exception => "",
                   :class_name => "NoMethodError",
                   :message => message)
      puts "Error: #{message}"
      exit
    end

    dates = source.date_range(month: args.month, year: args.year)

    dates.each do |date|
      journals_with_errors = source.get_feed(date[:month], date[:year])
      if journals_with_errors.empty?
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} have been saved"
      else
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} could not be saved for #{journals_with_errors.join(', ')}"
        exit
      end
      journals_with_errors = source.parse_feed(date[:month], date[:year])
      if journals_with_errors.empty?
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} have been parsed"
      else
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} could not be parsed for #{journals_with_errors.join(', ')}"
      end
    end
  end
end
