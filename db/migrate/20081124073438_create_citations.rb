# $HeadURL: http://ambraproject.org/svn/plos/alm/head/db/migrate/20081124073438_create_citations.rb $
# $Id: 20081124073438_create_citations.rb 5693 2010-12-03 19:09:53Z josowski $
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

class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.integer :article_id
      t.integer :retrieval_id
      t.string :uri
      t.text :abstract

      t.timestamps
    end
    
    add_column :articles, :citations_count, :integer, :default => 0

    Citation.reset_column_information
    Article.reset_column_information
    Article.find(:all).each do |article|
      Article.update_counters(article.id, 
        :citations_count => article.citations.length)
    end
  end

  def self.down
    drop_table :citations
  end
end
