# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

class RetrievalHistory < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  belongs_to :retrieval_status
  belongs_to :article
  belongs_to :source

  def self.delete_all(start_date, end_date)
    number = 0
    RetrievalHistory.where("created_at >= ? AND created_at <= ?", start_date, end_date).find_in_batches do |ids|
      self.delay(priority: 0, queue: "couchdb-queue").delete_documents(ids)
      number += ids.length
    end
    number
  end

  def self.delete_documents(ids)
    ids.each do |id|
      rh = RetrievalHistory.find(id)
      rh.delete_document
    end
  end

  def delete_document
    data_rev = get_alm_rev(id)
    remove_alm_data(id, data_rev)
  end
end
