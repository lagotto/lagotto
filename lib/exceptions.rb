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

# Custom exceptions defined for this application

module Exceptions
  # source is either not active or disabled
  class SourceInactiveError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end

  # class of errors in API responses
  class ApiResponseError < StandardError; end

  # the event count received from a source is decreasing
  class EventCountDecreasingError < ApiResponseError; end

  # the event count received from a source is increasing too fast
  class EventCountIncreasingTooFastError < ApiResponseError; end

  # the ratio of HTML views to PDF downloads is too high
  class HtmlPdfRatioError < ApiResponseError; end

  # too many tweets for the same article from the same account
  class MultipleTweetsError < ApiResponseError; end
end
