# encoding: UTF-8

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

namespace :filter do

  desc "Create alerts by filtering API responses"
  task :all => :environment do
    response = Filter.all
    if response.nil?
      puts "Found 0 unresolved API responses"
    else
      response[:review_messages].each { |review_message| puts review_message }
      puts response[:message]
    end
  end

  desc "Unresolve all alerts"
  task :unresolve => :environment do
    response = Filter.unresolve
    puts response[:message]
  end
end
