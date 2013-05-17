# This module imports crossref DOIs into ALM

namespace :crossref do

  desc "Parses the CrossRef json file into blocks of tab-delineated files for importing into ALM. Specify SOURCE, OUTPUT and BLOCKSIZE as environment variables."
  task :parse_json => :environment do

    source = ENV['SOURCE']
    output = ENV['OUTPUT']
    blocksize = ENV['BLOCKSIZE']

    if blocksize.blank?
      blocksize = 100000
      puts "Warning: using a default BLOCKSIZE of: #{blocksize}"
    else
      blocksize = blocksize.to_i
    end

    if source.blank? || output.blank?
      puts "Please specify both the SOURCE json file and the OUTPUT directory as environment variables, e.g."
      puts "$ bundle exec rake crossref:parse_json SOURCE=/path/to/source.json OUTPUT=/path/to/output/ BLOCKSIZE=100000"
    else
      if File.exists?(source)
        CrossrefImport.parse_json(source, output, blocksize)

        CrossrefImport.import_tabs(output)

      else
        puts "SOURCE file does not exist: #{source}"
      end
    end
  end
end