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

namespace :f1000 do

  desc "Bulk-import F1000Prime data"
  task :update => :environment do
    # silently exit if f1000 source is not available
    source = Source.active.find_by_name("f1000")
    exit if source.nil?

    unless source.get_feed
      puts "An error occured while saving the F1000 feed"
      exit
    else
      puts "The F1000 feed has been saved."
    end
    unless source.parse_feed
      puts "An error occured while parsing the F1000 feed"
      exit
    else
      puts "The F1000 feed has been parsed."
    end
  end
end
