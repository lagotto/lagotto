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

  def self.delete_many_documents(options = {})
    number = 0

    start_date = options[:start_date] || Date.today - 5.years
    end_date = options[:end_date] || Date.today
    collection = RetrievalHistory.where(created_at: start_date..end_date)

    collection.find_in_batches do |retrieval_histories|
      RetrievalHistory.delay(priority: 0, queue: "couchdb-queue").delete_documents(retrieval_histories)
      number += retrieval_histories.length
    end
    number
  end

  def self.delete_documents(retrieval_histories)
    retrieval_histories.each { |rh| rh.delete_document }
  end

  def delete_document
    data_rev = get_alm_rev(id)
    remove_alm_data(id, data_rev)
  end
end
