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

  desc "Raise all errors found in api responses and flag them as resolved"
  task :all => :environment do
    result = Filter.all
    if result[:decreasing] > 0
      puts "Raised #{result[:decreasing]} decreasing event count error(s)"
    else
      puts "Found no decreasing event count errors"
    end

    if result[:increasing] > 0
      puts "Raised #{result[:increasing]} increasing event count error(s)"
    else
      puts "Found no increasing event count errors"
    end

    if result[:slow] > 0
      puts "Raised #{result[:slow]} slow API response error(s)"
    else
      puts "Found no slow API response errors"
    end

    if result[:resolve] > 0
      puts "#{result[:resolve]} API response(s) flagged as resolved"
    else
      puts "No API responses flagged as resolved"
    end
  end
end
