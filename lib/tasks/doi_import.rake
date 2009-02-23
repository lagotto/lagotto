require 'doi'

desc "Bulk-import DOIs from standard input"
task :doi_import => :environment do
  puts "Reading DOIs from standard input..."
  valid = []
  invalid = []
  duplicate = []
  created = []
  updated = []
  while (line = STDIN.gets)
    raw_doi, raw_published_on = line.strip.split(" ")
    raw_doi.strip!
    raw_published_on.strip!
    doi = DOI::from_uri raw_doi
    published_on = Date.parse(raw_published_on)
    if (doi =~ DOI::FORMAT) and !published_on.nil?
      valid << [doi, published_on]
    else
      invalid << [raw_doi, published_on]
    end
  end
  puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"
  if invalid.size == 0
    valid.each do |doi, published_on| 
      existing = Article.find_by_doi(doi)
      unless existing
        Article.create(:doi => doi, :published_on => published_on)
        created << doi
      else
        if existing.published_on != published_on
          existing.published_on = published_on
          existing.save!
          updated << doi
        else
          duplicate << doi
        end
      end
    end
  end
  puts "Saved #{created.size} new articles, updated #{updated.size} articles, ignored #{duplicate.size} other existing articles"
end
