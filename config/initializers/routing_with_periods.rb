# $HeadURL: http://ambraproject.org/svn/plos/alm/head/config/initializers/routing_with_periods.rb $
# $Id: routing_with_periods.rb 5693 2010-12-03 19:09:53Z josowski $
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
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

# this hack coupled with config/routes.rb:
#   map.resources :articles, :requirements => { :id => /.+?/ }
#
# allows periods in the :id of routes, but limits us fully known MIME types.
ActionController::Routing::OptionalFormatSegment.class_eval do
  @@types = Mime::SET.map(&:to_sym).join('|')
  def regexp_chunk
    "/|(\\.(#{@@types}))?"
  end
end
