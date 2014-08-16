# encoding: UTF-8

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

namespace :couchdb do
  namespace :histories do
    desc "delete CouchDB history documents"
    task :delete => :environment do |t, args|
      options = { start_date: ENV['START_DATE'],
                  end_date: ENV['END_DATE'] }
      number = RetrievalHistory.delete_many_documents(options)
      if number > 0
        puts "Deleting #{number} CouchDB history documents in the background..."
      else
        puts "No CouchDB history documents to delete."
      end
    end
  end
end
