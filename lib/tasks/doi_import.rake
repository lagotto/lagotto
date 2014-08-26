desc "Bulk-import DOIs from standard input"
task :doi_import => :environment do
  Rake::Task["db:articles:load"].invoke
  Rake::Task["db:articles:load"].reenable
end

# This should be used only when you are trying to sync up articles in alm with articles in ambra database
task :cleanup_plos_articles => :environment do
  puts "Reading DOIs from standard input..."
  valid = []
  invalid = []

  while (line = STDIN.gets)
    line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
    raw_doi, raw_published_on, raw_title = line.strip.split(" ", 3)

    doi = Article.from_uri(raw_doi.strip).values.first
    published_on = Date.parse(raw_published_on.strip) if raw_published_on
    title = raw_title.strip if raw_title
    if (doi =~ DOI_FORMAT) and !published_on.nil? and !title.nil?
      valid << doi
    else
      puts "Ignoring DOI: #{raw_doi}, #{raw_published_on}, #{raw_title}"
      invalid << raw_doi
    end
  end

  puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries;"

  articles_from_alm = Article.where("doi like '10.1371/journal.p%'").pluck(:doi)

  # get articles that are in alm but not in ambra
  bad_articles = articles_from_alm - valid

  bad_articles.each do | doi |
    article = Article.find_by_doi(doi)
    puts "deleting article #{article.doi}, #{article.title}, #{article.published_on}"
    Article.destroy(article.id)
  end

  puts "Deleted #{bad_articles.size} articles"
end
