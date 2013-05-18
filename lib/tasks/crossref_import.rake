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

        #CrossrefImport.import_tabs(output)

      else
        puts "SOURCE file does not exist: #{source}"
      end
    end
  end


  desc "Imports the CrossRef tab-delineated files into ALM. Specify TAB_DIR and DELAY as an environment variable."
  task :import_tabs => :environment do

    tab_dir = ENV['TAB_DIR']
    delay = ENV['DELAY']


    if delay.blank?
      delay = 20
      puts "Warning: using a default DELAY of: #{delay} seconds"
    else
      delay = delay.to_i
    end

    if tab_dir.blank?
      puts "Please specify the TAB_DIR directory as an environment variable, e.g."
      puts "$ bundle exec rake crossref:import_tabs TAB_DIR=/path/to/tabs/ DELAY=20"
    else
      if Dir.exists?(tab_dir)
        CrossrefImport.import_tabs(tab_dir, delay)
      else
        puts "TAB_DIR directory does not exist: #{tab_dir}"
      end
    end
  end
end