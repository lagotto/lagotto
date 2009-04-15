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
    raw_doi, raw_published_on, raw_volume, raw_issue, raw_title = line.strip.split(" ", 5)
    doi = DOI::from_uri raw_doi.strip
    published_on = Date.parse(raw_published_on.strip) if raw_published_on
    volume = raw_volume.strip if raw_volume
    issue = raw_issue.strip if raw_issue
    title = raw_title.strip if raw_title
    if (doi =~ DOI::FORMAT) and published_on and volume and issue and title
      valid << [doi, published_on, volume, issue, title]
    else
      invalid << [raw_doi, raw_published_on, raw_volume, raw_issue, raw_title]
    end
  end
  puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"
  if invalid.size == 0
    valid.each do |doi, published_on, volume, issue, title| 
      existing = Article.find_by_doi(doi)
      unless existing
        Article.create(:doi => doi, :published_on => published_on, 
                       :volume => volume, :issue => issue,
                       :title => title)
        created << doi
      else
        if (existing.published_on != published_on or \
            existing.volume != volume or \
            existing.issue != issue or \
            existing.title != title)
          existing.published_on = published_on
          existing.volume = volume
          existing.issue = issue
          existing.title = title
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
