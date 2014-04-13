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

Dir[File.join(Rails.root, 'lib', '*.rb')].each { |f| require f }

include CustomError

ActiveSupport::XmlMini.backend = 'Nokogiri'

# Global constants
DEFAULT_TIMEOUT = 60
NETWORKABLE_EXCEPTIONS = [Faraday::Error::ClientError,
                          Delayed::WorkerTimeout,
                          Encoding::UndefinedConversionError,
                          ArgumentError]
                          # Errno::EPIPE, Errno::ECONNRESET

# Format used for DOI validation - we want to store DOIs without
# the leading "info:doi/"
DOI_FORMAT = %r(^\d+\.[^/]+/[^/]+)
