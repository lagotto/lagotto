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

class AddGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.timestamps
    end
    
    add_column :sources, :group_id, :integer, { :null => true }
    
    execute "insert into groups(name) values('Social Bookmarks');"
    execute "insert into groups(name) values('Citations');"
    execute "insert into groups(name) values('Blog Entries');"
    execute "insert into groups(name) values('Statistics');"
  end

  def self.down
    remove_column :sources,:group_id
    
    drop_table :groups
  end
end
