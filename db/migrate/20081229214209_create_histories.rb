# $HeadURL: http://ambraproject.org/svn/plos/alm/head/db/migrate/20081229214209_create_histories.rb $
# $Id: 20081229214209_create_histories.rb 5693 2010-12-03 19:09:53Z josowski $
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

class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.integer :retrieval_id, :null => false
      t.integer :year, :null => false
      t.integer :month, :null => false
      t.integer :citations_count, :default => 0
      t.timestamps
    end
    add_index :histories, [:retrieval_id, :year, :month], :unique => true
  end

  def self.down
    drop_table :histories
    remove_index :histories, [:retrieval_id, :year, :month]
  end
end
