#
# Copyright 2015-2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'pathname'


module PoiseService
  # Utility methods for PoiseService.
  #
  # @api public
  # @since 1.0.0
  module Utils
    # Methods are also available as module-level methods as well as a mixin.
    extend self

    # Common segments to ignore
    COMMON_SEGMENTS = %w{var www current etc}.inject({}) {|memo, seg| memo[seg] = true; memo }

    # Parse the service name from a path. Look at the last component of the
    # path, ignoring some common names.
    #
    # @param path [String] Path to parse.
    # @return [String]
    # @example
    #   attribute(:service_name, kind_of: String, default: lazy { PoiseService::Utils.parse_service_name(path) })
    def parse_service_name(path)
      parts = Pathname.new(path).each_filename.to_a.reverse!
      # Find the last segment not in common segments, fall back to the last segment.
      parts.find {|seg| !COMMON_SEGMENTS[seg] } || parts.first
    end
  end
end
