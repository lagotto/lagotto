require 'doi'

namespace :db do
  task :update => :"db:update:stale"
  namespace :update do
    desc "Update stale articles"
    task :stale => :environment do
      limit = (ENV["LIMIT"] || 0).to_i
      stale_threshold = Date.today - Source.maximum_staleness
      articles = ENV["LAZY"] == "0" \
        ? Article.limit(limit) \
        : Article.not_refreshed_since(stale_threshold).limit(limit)
      puts "Updating #{articles.size} stale articles"
      update_articles(articles)
    end

    desc "Update all articles"
    task :all => :environment do
      ENV["LAZY"] = "0"
      limit = (ENV["LIMIT"] || 0).to_i
      articles = Article.limit(limit)
      puts "Updating #{articles.size} articles"
      update_articles(articles)
    end

    desc "Update cited articles"
    task :cited => :environment do
      limit = (ENV["LIMIT"] || 0).to_i
      articles = Article.cited.limit(limit)
      puts "Updating #{articles.size} cited articles"
      update_articles(articles)
    end

    desc "Update one specified article"
    task :one => :environment do
      doi = ENV["DOI"] or abort("DOI not specified (eg, 'DOI=10.1371/foo')")
      article = Article.find_by_doi(doi) or abort("Article not found: #{doi}")
      ENV["LAZY"] ||= "0"
      ENV["VERBOSE"] ||= "1"
      update_articles([article])
    end

    def update_articles(articles)
      verbose = ENV.fetch("VERBOSE", "0").to_i
      lazy = ENV.fetch("LAZY", "1") == "1"
      retriever = Retriever.new(:lazy => lazy,
        :only_source => ENV["SOURCE"], :verbose => verbose,
        :raise_on_error => ENV["RAISE_ON_ERROR"])
        
      articles.each do |article|
        old_count = article.citations_count
        retriever.update(article)
        if verbose
          delta = article.citations_count - old_count
          puts "  #{article.doi} count now #{article.citations_count} (#{delta})" if delta != 0
        end
      end
    end

    desc "Reset articles so individual sources' dates will be reconsidered"
    task :reset => :environment do
      Article.update_all("retrieved_at = '2000-01-01 00:00:00'")
    end

    desc "Reset all retrievals and citations"
    task :reset_all => :environment do
      Retrieval.delete_all
      Citation.delete_all
      History.delete_all
      Article.update_all("retrieved_at = '2000-01-01 00:00:00'")
    end
  end
end
