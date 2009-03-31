require 'doi'

namespace :db do
  task :update => :"db:update:stale"
  namespace :update do
    desc "Update stale articles"
    task :stale => :environment do
      limit = (ENV["LIMIT"] || 0).to_i
      articles = if ENV["DOI"]
        doi = ENV["DOI"]
        ENV["LAZY"] ||= "0"
        article = Article.find_by_doi(doi) or abort("Article not found: #{doi}")
        [article]
      elsif ENV["LAZY"] == "0"
        Article.limit(limit)
      else
        stale_threshold = Date.today - Source.maximum_staleness
        Article.not_refreshed_since(stale_threshold).limit(limit)
      end

      update_articles(articles)
    end

    desc "Update all articles"
    task :all => :environment do
      ENV["LAZY"] = "0"
      limit = (ENV["LIMIT"] || 0).to_i
      articles = Article.limit(limit)
      update_articles(articles)
    end

    desc "Update cited articles"
    task :cited => :environment do
      limit = (ENV["LIMIT"] || 0).to_i
      articles = Article.cited.limit(limit)
      update_articles(articles, "cited")
    end

    desc "Update one specified article"
    task :one => :environment do
      doi = ENV["DOI"] or abort("DOI not specified (eg, 'DOI=10.1371/foo')")
      article = Article.find_by_doi(doi) or abort("Article not found: #{doi}")
      ENV["LAZY"] ||= "0"
      ENV["VERBOSE"] ||= "1"
      update_articles([article])
    end

    desc "Count stale articles"
    task :count => :environment do
      stale_threshold = Date.today - Source.maximum_staleness
      article_count = Article.not_refreshed_since(stale_threshold).count
      puts "#{article_count} stale articles found"
    end

    def update_articles(articles, adjective=nil)
      lazy = ENV.fetch("LAZY", "1") == "1"
      puts ["Updating", articles.size.to_s, 
            lazy ? "stale" : nil, adjective,
            articles.size == 1 ? "article" : "articles"].compact.join(" ")
      verbose = ENV.fetch("VERBOSE", "0").to_i
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

    desc "Scan database for duplicate citations"
    task :dup_check => :environment do
      Retrieval.all.each do |retrieval|
        dups = []
        citations_by_uri = retrieval.citations.inject({}) do |h, citation|
          dups << citation if (h[citation.uri] ||= citation) != citation
          h
        end
        unless dups.empty?
          dups.each do |citation|
            puts "#{retrieval.article.doi} from #{retrieval.source.name} includes extra #{citation.uri}: #{citation.id}"
            if ENV['CLEANUP']
              puts "deleting citation #{citation.id}" if verbose
              retrieval.citations.delete(citation)
            end
          end
          if ENV['CLEANUP']
            new_count = retrieval.citations.size
            retrieval.histories.each do |h|
              if h.citations_count > new_count
                puts "updating history #{h.id}" if verbose
                h.citations_count = new_count
                h.save!
              end
            end
          end
        end
      end
    end
  end
end
