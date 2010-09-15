# $HeadURL$
# $Id$
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

module SecondsToDuration
  def self.convert(seconds)
    return seconds if (ActiveSupport::Duration === seconds)
    return (seconds / 1.day).days if (seconds % 1.day == 0)
    return (seconds / 1.hour).hours if (seconds % 1.hour == 0)
    return (seconds / 1.minute).minutes if (seconds % 1.minute == 0)
    seconds.seconds
  end
end
