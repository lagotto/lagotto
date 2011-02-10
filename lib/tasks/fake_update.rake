# $HeadURL: http://ambraproject.org/svn/plos/alm/head/lib/tasks/fake_update.rake $
# $Id: fake_update.rake 5693 2010-12-03 19:09:53Z josowski $
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

require 'doi'

namespace :db do
  namespace :update do
    desc "Update an article with bogus history, for testing"
    task :fake => :environment do
      doi = ENV["DOI"] || "10.1371/bogus"
      puts "Creating fake history for #{doi}"
      article = Article.find_or_create_by_doi(doi, :pub_med => "pm_bogus",
        :pub_med_central => "pmc_bogus")
      article.published_on = article.created_at.to_date
      article.save!
      article.retrievals.destroy_all
      Source.active.each do |source|
        puts "  #{source.name}"
        retrieval = article.retrievals.find_or_create_by_source_id(source.id)

        # For this source, create history
        citations_left = total_citations = (2 ** rand(6)) + rand(6)
        current_month = 0
        while citations_left > 0 do
          # go month by month, creating histories
          month_citations = rand(citations_left+1)
          month_retrieved_at = current_month.months.ago
          year = month_retrieved_at.year
          month = month_retrieved_at.month
          if month_citations > 0
            puts "    #{month_citations} #{current_month} months ago"
            unless source.is_a? Scopus # (Scopus only tracks counts)
              # Create this month's citations
              1.step(month_citations) do |i|
                c = retrieval.citations.create(:uri => "http://example.com/bogus/#{doi}/#{source.name}/#{year}_#{month}/#{i}")
                puts "      #{c.uri}"
              end
            end
          end

          # Create a history for this month
          retrieval.histories.create(:year => year, :month => month,
            :citations_count => citations_left)
          citations_left -= month_citations
          current_month += 1
        end
        
        retrieval.reload
        retrieval.other_citations_count = total_citations \
          if source.is_a? Scopus
        retrieval.retrieved_at = DateTime.now.utc
        retrieval.save!
      end
    end
  end
end
