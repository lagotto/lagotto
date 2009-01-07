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
        total_citations = 0
        months = (2 ** rand(5)) - 1
        if months > 0
          0.step(months-1) do |m|
            # go month by month, creating histories
            month_citations = (4 ** rand(3)) - 1
            if month_citations > 0
              puts "    #{month_citations} #{m} months ago"
              unless source.is_a? Scopus # (Scopus only tracks counts)
                # Create this month's citations
                1.step(month_citations) do |i|
                  c = retrieval.citations.create(:uri => "http://example.com/bogus/#{doi}/#{source.name}/#{m}/#{i}")
                  puts "      #{c.uri}"
                end
              end

              # Create a history for this month
              total_citations += month_citations
              puts "  #{total_citations} total from this source"
              month_retrieved_at = m.months.ago
              retrieval.histories.create(:year => month_retrieved_at.year,
                :month => month_retrieved_at.month,
                :citations_count => month_citations)
            end
          end
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
