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

module DOI
  # Format used for validation - we want to store DOIs without
  # the leading "info:doi/"
  FORMAT = %r(\d+\.[^/]+/[^/]+)

  def self.from_uri(doi)
    return nil if doi.nil?
    doi = doi.gsub("%2F", "/")
    if doi.starts_with? "http://dx.doi.org/"
      doi = doi[18..-1]
    end
    if doi.starts_with? "info:doi/"
      doi = doi[9..-1]
    end
    doi
  end

  def self.to_uri(doi, escaped=true)
    return nil if doi.nil?
    unless doi.starts_with? "info:doi"
      doi = "info:doi/" + from_uri(doi)
    end
    doi
  end

  def self.to_url(doi)
    return nil if doi.nil?
    unless doi.starts_with? "http://dx.doi.org/"
      doi = "http://dx.doi.org/" + from_uri(doi)
    end
    doi
  end
end