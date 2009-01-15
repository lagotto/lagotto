require 'doi'

namespace :db do
  namespace :update do
    desc "Update an article with bogus history, for testing"
    task :fake => :environment do
      doi = ENV["DOI"] || "10.1371/bogus"
      puts "Creating fake history for #{doi}"
      article = Article.find_or_create_by_doi(doi, :pub_med => "pm_bogus",
        :pub_med_central => "pmc_bogus")
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
