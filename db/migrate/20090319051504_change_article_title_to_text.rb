# $HeadURL: http://ambraproject.org/svn/plos/alm/head/db/migrate/20090319051504_change_article_title_to_text.rb $
# $Id: 20090319051504_change_article_title_to_text.rb 5693 2010-12-03 19:09:53Z josowski $
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

class ChangeArticleTitleToText < ActiveRecord::Migration
  def self.up
    change_column :articles, :title, :text
  end

  def self.down
    change_column :articles, :title, :string
  end
end
