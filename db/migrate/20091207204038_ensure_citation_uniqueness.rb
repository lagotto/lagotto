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

class EnsureCitationUniqueness < ActiveRecord::Migration
  def self.up
    #Clean up Duplicate Citations

    execute "create table citation_dupes SELECT a.id as article_id, r.source_id, c.uri as uri, count(*) as citationDupped FROM citations c join retrievals r on r.id = c.retrieval_id join articles a on a.id = r.article_id group by a.id, r.source_id,c.uri having count(*) > 1;"
    execute "create table citation_latest_dupe_id select max(c.id) as citation_id,c.uri from citations c join retrievals r on c.retrieval_id = r.id join citation_dupes d on c.uri = d.uri and d.source_id = r.source_id and d.article_id = r.article_id group by c.uri,d.article_id,d.source_id;"
    execute "create table citation_dupes_to_delete select d2.citation_id,c.* from citations c join retrievals r on c.retrieval_id = r.id join citation_dupes d on c.uri = d.uri and d.source_id = r.source_id and d.article_id = r.article_id left outer join citation_latest_dupe_id d2 on c.id = d2.citation_id where d2.citation_id is null;"

    execute "delete from citations where id in (select id from citation_dupes_to_delete);"

    execute "drop table citation_dupes_to_delete;"
    execute "drop table citation_latest_dupe_id;"
    execute "drop table citation_dupes;"

    #Clean up Duplicate Retrievals

    execute "create table retrieval_dupes select article_id,source_id,count(*) as dupeCount from retrievals group by article_id,source_id having count(*) > 1;"
    execute "create table retrieval_latest_dupe_id select r.article_id,r.source_id,min(r.id) as retireval_id from retrievals r join retrieval_dupes rd on rd.source_id = r.source_id and rd.article_id = r.article_id group by r.article_id,r.source_id;"
    execute "create table retrievals_to_delete select r.id as retrieval_id from retrievals r join retrieval_dupes rd on r.source_id = rd.source_id and r.article_id = rd.article_id where r.id not in (select retireval_id from retrieval_latest_dupe_id);"

    execute "delete from citations where retrieval_id in (select retrieval_id from retrievals_to_delete);"
    execute "delete from retrievals where id in (select retrieval_id from retrievals_to_delete);"

    execute "drop table retrieval_dupes;"
    execute "drop table retrieval_latest_dupe_id;"
    execute "drop table retrievals_to_delete;"
    
    change_column :citations,  :uri, :string, { :null => false }
    add_index :citations, [:retrieval_id, :uri], :unique => true
    add_index :retrievals, [:source_id, :article_id], :unique => true
  end

  def self.down
    change_column :citations,  :uri, :string, { :null => true }
    remove_index :citations, [:retrieval_id, :uri]
    remove_index :retrievals, [:source_id, :article_id]
  end
end


