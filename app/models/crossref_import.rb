require 'json'

class CrossrefImport
  # This method reads the given JSON file, parses DOIs, Dates and Title,
  # and creates a set of txt files to import

  CURRENT_YEAR = DateTime.now.year


  def self.parse_json(json_file, output_dir, block_size)

    start_time = Time.new

    unless File.exists?(json_file)
      raise ArgumentError.new("File #{json_file} does not exist")
    end

    unless Dir.exists?(output_dir)
      FileUtils.mkdir_p(output_dir)
    end

    existing_files = Dir.glob(File.absolute_path("*.crossref.*", output_dir))

    if existing_files.count > 0
      puts "Warning: there were #{existing_files.count} existing *.crossref file(s) in #{output_dir}\nThey will be deleted"
      existing_files.each do |filename|
        File.delete filename
        puts "Deleted #{filename}"
      end
    end


    # Calculate some useful numbers
    line_count = %x{wc -l #{json_file}}.split.first.to_i
    if line_count <  block_size
      file_count = 1
    elsif  line_count % block_size == 0
      file_count = line_count / block_size
    else
      file_count = (line_count / block_size) + 1
    end
    file_counter_precision = (Math.log10(file_count)).to_i + 1

    file_counter = 1 #start at one!
    line_counter = 0 #start at zero!

    output_file = self.get_incremental_file(output_dir, File.basename(json_file), file_counter, file_counter_precision)
    #output_file = get_output_file(file_counter, file_counter_precision, output_dir, json_file)
    error_file = nil
    invalid_record_counter = 0
    valid_record_counter = 0

    file = File.open(json_file)
    file.each_line do |line|

      begin
        error = false
        error_msg = nil

        data = JSON.parse(line)

        doi = Article.from_uri(data["doi"].strip).values.first
        title = data["title"].blank? ? nil : data["title"].strip
        published_on = self.parse_date(data["published"])

      rescue
        error = true
        error_msg = $!

      ensure

        #Is there an error processing this line?
        if (error || !(doi =~ Article::FORMAT) || title.nil? || published_on.nil?)
          invalid_record_counter += 1

          #Construct an appropriate error message if an exception was not thrown
          if !error
            error_msg = "doi invalid" unless (doi =~ Article::FORMAT)
            error_msg = "title missing" if title.nil?
            error_msg = "published_on missing" if published_on.nil?
          end

          error_file ||= self.open_file(output_dir, File.basename(json_file), ".crossref.errors")
          error_file.write("#{error_msg}\t" + line)
        else
          output_file.write "#{data["doi"]}\t#{published_on}\t#{title}\n"
          line_counter += 1
          valid_record_counter += 1
        end
      end

      if (file.lineno < line_count && line_counter > 0 && line_counter % block_size == 0)
        # Close the current output file and create a new one
        output_file.close()
        file_counter += 1
        line_counter = 0
        output_file = self.get_incremental_file(output_dir, File.basename(json_file), file_counter, file_counter_precision)
      end


    end
    output_file.close()
    error_file.close() unless error_file.nil?
    file.close

    stop_time = Time.new


    puts ""
    puts "PROCESSING STATISTICS"
    puts "Valid lines processed:\t" << valid_record_counter.to_s
    puts "Invalid lines skipped:\t" << invalid_record_counter.to_s
    puts "Source file line count:\t" << line_count.to_s
    puts "Output file count:\t" << file_counter.to_s
    puts "PROCESSING ERROR: Unaccounted for lines:\t" << (line_count - (valid_record_counter + invalid_record_counter)).to_s if (line_count != (valid_record_counter + invalid_record_counter))
    puts "Total time elapsed (seconds):\t" << (stop_time - start_time).to_s
    puts "Processing rate (lines/second):\t%.1f" % (line_count.to_f / (stop_time - start_time).to_f)
    puts "Error rate:\t%.3f%" % (100.0 * invalid_record_counter.to_f / line_count.to_f) if line_count > 0

    puts ""
    puts "All done"
  end


  def self.import_tabs(source_dir)
    start_time = Time.new
    puts "in IMPORT TABS"

    invalid_record_counter = 0
    valid_record_counter = 0
    line_count = 0
    file_count = 0
    duplicate_count = 0
    created_count = 0
    updated_count = 0


    # Process in reverse sorted order to do latest articles first
    tab_files_list = Dir.glob(File.absolute_path("*.crossref.[0-9]*.tab", source_dir)).sort.reverse
    tab_files_list.each do |tab_file|
      file_count += 1
      error_file = nil
      output_file = self.open_file(source_dir, File.basename(tab_file), ".processed")


      puts "Processing #{tab_file}"
      file = File.open( tab_file )

      file.each_line do |line|
        line_count += 1



        begin
          error = false
          error_msg = nil

          raw_doi, raw_published_on, raw_title = line.strip.split("\t", 3)

          doi = Article.from_uri(raw_doi.strip).values.first
          title = raw_title.strip if raw_title
          published_on = Date.parse(raw_published_on.strip) if raw_published_on

        rescue
          error = true
          error_msg = $!

        ensure

          #Is there an error processing this line?
          if (error || !(doi =~ Article::FORMAT) || title.nil? || published_on.nil?)
            invalid_record_counter += 1

            #Construct an appropriate error message if an exception was not thrown
            if !error
              error_msg = "doi invalid" unless (doi =~ Article::FORMAT)
              error_msg = "title missing" if title.nil?
              error_msg = "published_on missing" if published_on.nil?
            end

            error_file ||= self.open_file(source_dir, File.basename(tab_file), ".errors")
            error_file.write("#{error_msg}\t" + line)
          else


            #Now load DOI
            existing = Article.find_by_doi(doi)
            unless existing
              article = Article.create(:doi => doi, :published_on => published_on, :title => title)
              created_count += 1
              output_file.write("created\t" + line)
            else
              if existing.published_on != published_on or existing.title != title
                existing.published_on = published_on
                existing.title = title
                existing.save!
                updated_count += 1
                output_file.write("updated\t" + line)
              else
                duplicate_count += 1
                output_file.write("duplicate\t" + line)
              end
            end

            valid_record_counter += 1
          end
        end #begin
      end #each_line



      error_file.close() unless error_file.nil?
      output_file.close()
      file.close()

      File.delete(tab_file) #delete the old input file (in its place will be a .processed file)

      break #Temporary

    end #each tab_file

    stop_time = Time.new

    puts ""
    puts "PROCESSING STATISTICS"
    puts "File count:\t" << file_count.to_s
    puts "Valid lines processed:\t" << valid_record_counter.to_s
    puts "Invalid lines skipped:\t" << invalid_record_counter.to_s

    puts "Created records:\t" << created_count.to_s
    puts "Updated records:\t" << updated_count.to_s
    puts "Duplicate records:\t" << duplicate_count.to_s

    puts "Total time elapsed (seconds):\t" << (stop_time - start_time).to_s
    puts "Processing rate (lines/second):\t%.1f" % (line_count.to_f / (stop_time - start_time).to_f)
    puts "Error rate:\t%.3f%" % (100.0 * invalid_record_counter.to_f / line_count.to_f) if line_count > 0

    puts ""
    puts "All done"

  end



  # Private methods -----------------
  private
  def self.get_incremental_file(output_dir, base_filename, file_counter, file_counter_precision)
    self.open_file(output_dir, base_filename, ".crossref.#{"%.#{file_counter_precision}i" % file_counter}.tab")
  end

  def self.open_file(output_dir, base_filename, extension)
    filename = base_filename + extension
    if File.exists?(File.join(output_dir, filename))
      puts "Opening #{filename}"
    else
      puts "Creating #{filename}"
    end
    File.open(File.join(output_dir, filename), 'w')
  end

  def self.parse_date(date_object)
    #Year must exist and must be between 2000 - current year
    if !date_object.nil? && !date_object["year"].nil?
      year = date_object["year"].to_i
      if year >= 2000 && year <= CURRENT_YEAR
        # If month is not provided, assume January
        if !date_object["month"].nil?
          month = date_object["month"].to_i

          case month
            when 1..12
              #do nothing
              nil


            when 21 #spring, assume this means northern hemisphere, March 20 - June 20, choose March
              month = 3
            when 22 #summer, assume this means northern hemisphere, June 21 - September 21, choose June
              month = 6
            when 23 #autumn, assume this means northern hemisphere, September 22 - December 20, choose September
              month = 9
            when 24 #winter, assume this means northern hemisphere, December 21 - March 19, choose December
              month = 12

            when 31 #quarter 1, assume this means January
              month = 1
            when 32 #quarter 2, assume this means April
              month = 4
            when 33 #quarter 3, assume this means July
              month = 7
            when 34 #quarter 4, assume this means October
              month = 10

            else
              #Unknown month, throw an error
              raise ArgumentError, "Month #{month} is unknown"
          end

          if !date_object["day"].nil?
            day = date_object["day"].to_i
          else
            day = 1
          end
        else
          #If no month provided, assume January
          month = 1

          #If no month is provided, assume day is 1st (rather than use day value when provided)
          day = 1
        end


        return Date.new(year, month, day)


      else
        #Unknown year, throw an error
        raise ArgumentError, "Year #{year} is unknown"
      end
    else
      #No data provided
      raise ArgumentError, "date_object is nil" if date_object.nil?
      raise ArgumentError, "date_object[\"year\"] is nil" if date_object["year"].nil?
    end
  end


end