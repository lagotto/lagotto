
namespace :queue do

  task :pmc => :environment do

    # this rake task should be scheduled to run after pmc data import rake task runs
    source = Source.find_by_name("pmc")
    source.queue_all_articles

  end

  task :counter => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("counter")
    source.queue_all_articles

  end

  task :biod => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("biod")
    source.queue_all_articles

  end

  task :citeulike => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("citeulike")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :crossref => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("crossref")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :nature => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("nature")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :mendeley => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("mendeley")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :researchblogging => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("researchblogging")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :wos => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("wos")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :pubmed => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("pubmed")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :scopus => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("scopus")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :facebook => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("facebook")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end
  
  task :wikipedia => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("wikipedia")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :single_job, [:doi, :source] => :environment do |t, args|
    if args.doi.nil?
      puts "DOI is required"
      exit
    end

    article = Article.find_by_doi(args.doi)
    if article.nil?
      puts "Article with doi #{args.doi} does not exist"
      exit
    end

    if args.source.nil?
      puts "Source is required"
      exit
    end

    source = Source.find_by_name(args.source)
    if source.nil?
      puts "Source with name #{args.source} does not exist"
      exit
    end

    rs = RetrievalStatus.find_by_article_id_and_source_id(article.id, source.id)
    
    # optionally repeat rake task n times to check for intermittend problems
    n = ENV['n'].to_i || 1
    (1..n).each do
      source.queue_article_job(rs)
      sleep 5 if n > 1
    end

    puts "Job for doi #{article.doi} and source #{source.display_name} has been queued."
  end

end

