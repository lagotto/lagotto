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

class DefaultRetrievalsRetrievedAtToEpoch < ActiveRecord::Migration
  def self.up
    change_column :retrievals, :retrieved_at, :datetime, :default => '1970-01-01 00:00:00'
    Retrieval.update_all "retrieved_at = '1970-01-01 00:00:00'", "retrieved_at IS NULL"
    change_column :retrievals, :retrieved_at, :datetime, :null => false
  end

  def self.down
    change_column :retrievals, :retrieved_at, :datetime, :null => true
    Retrieval.update_all "retrieved_at = NULL", "retrieved_at = '1970-01-01 00:00:00'"
    change_column :retrievals, :retrieved_at, :datetime, :default => nil
  end
end
