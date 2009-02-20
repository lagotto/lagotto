require 'doi'

desc "Bulk-import DOIs from standard input"
task :doi_import => :environment do
  puts "Reading DOIs from standard input..."
  valid_dois = []
  invalid_dois = []
  duplicate_dois = []
  created_dois = []
  while (raw_doi = STDIN.gets)
    raw_doi.strip!
    doi = DOI::from_uri raw_doi
    if doi =~ DOI::FORMAT
      valid_dois << doi
    else
      invalid_dois << raw_doi
    end
  end
  puts "Read #{valid_dois.size} valid DOIs; ignored #{invalid_dois.size} invalid DOIs"
  if invalid_dois.size == 0
    valid_dois.each do |doi| 
      unless Article.find_by_doi(doi)
        Article.create(:doi => doi)
        created_dois << doi
      else
        duplicate_dois << doi
      end
    end
  end
  puts "Saved #{created_dois.size} new DOIs, ignored #{duplicate_dois.size} duplicate DOIs"
end
