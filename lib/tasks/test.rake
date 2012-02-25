
namespace :generate_test_data do
  
  task :pmc => :environment do

    source = Source.new
    source.name = "pmc"
    source.display_name = "PubMed Central Usage Stats"
    source.active = true
    source.batch_size = 5000
    source.workers = 1
    source.save

    @articles = []
    limit = 5000
    offset = 0

    begin
      @articles = Article.find :all,
                               :limit  =>  limit,
                               :offset =>  offset
      offset += limit

      puts "#{@articles.size} #{limit} #{offset}"

      @articles.each do |article|
        retrieval = Retrieval.new
        retrieval.article_id = article.id
        retrieval.source_id = source.id
        retrieval.save
      end

    end while @articles.size == limit

  end

  task :counter => :environment do
    source = Source.new
    source.name = "counter"
    source.display_name = "Counter"
    source.active = true
    source.batch_size = 5000
    source.workers = 2
    source.save

    @articles = []
    limit = 5000
    offset = 0

    begin
      @articles = Article.find :all,
                               :limit  =>  limit,
                               :offset =>  offset
      offset += limit

      puts "#{@articles.size} #{limit} #{offset}"

      @articles.each do |article|
        retrieval = Retrieval.new
        retrieval.article_id = article.id
        retrieval.source_id = source.id
        retrieval.save
      end

    end while @articles.size == limit

  end

  task :twitter => :environment do
    source = Source.new
    source.name = "twitter"
    source.display_name = "Twitter"
    source.active = true
    source.batch_size = 5000
    source.workers = 2
    source.save

    @articles = []
    limit = 5000
    offset = 0
    
    begin
      @articles = Article.find :all,
                               :limit  =>  limit,
                               :offset =>  offset
      offset += limit

      puts "#{@articles.size} #{limit} #{offset}"

      @articles.each do |article|
        retrieval = Retrieval.new
        retrieval.article_id = article.id
        retrieval.source_id = source.id
        retrieval.save
      end

    end while @articles.size == limit
    
  end

  task :all => :environment do
    Rake::Task['generate_test_data:pmc'].invoke
    Rake::Task['generate_test_data:counter'].invoke
    Rake::Task['generate_test_data:twitter'].invoke
  end
end