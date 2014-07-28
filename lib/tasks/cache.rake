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

namespace :cache do

  desc "Update cached API responses for admin dashboard"
  task :update => :environment do
    status = Status.new
    status.update_cache
    puts "Cache update for status page has been queued."

    sources = Source.active
    sources.each do |source|
      source.update_cache
      puts "Cache update for source #{source.display_name} has been queued."
    end
  end

  desc "Expire all API cache keys"
  task :expire => :environment do
    ApiCacheKey.expire_all
    puts "Expired all API cache keys"
  end

  task :default => :update

end
