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

class FixCitationCounting < ActiveRecord::Migration
  class Article < ActiveRecord::Base; end
  class Retrieval < ActiveRecord::Base;
    has_many :citations
  end

  def self.up
    remove_column "articles", "citations_count"
    add_column "retrievals", "citations_count", :integer, :default => 0
    add_column "retrievals", "other_citations_count", :integer, :default => 0

    Retrieval.reset_column_information
    Retrieval.all.each do |r|
      Retrieval.update_counters r.id, :citations_count => r.citations.length
    end
  end

  def self.down
    add_column "articles", "citations_count", :integer, :default => 0
    remove_column "retrievals", "citations_count"
    remove_column "retrievals", "other_citations_count"
  end
end
