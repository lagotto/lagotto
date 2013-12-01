# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2013 by Public Library of Science, a non-profit corporation
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

class ApiCache < ActiveRecord::Base

  class << self
    def expire_all
      ApiCacheKey.all.each do |cache_key|
        cache_key.touch
        url = "http://localhost/api/v3/#{cache_key.name}?api_key=#{api_key}"
        response = get_json(url)
      end
    end
    handle_asynchronously :expire_all, priority: 0, queue: "api-cache"

    def api_key
      APP_CONFIG['api_key']
    end
  end
end