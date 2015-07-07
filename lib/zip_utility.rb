class ZipUtility
  attr_reader :filepath, :permissions, :files_to_be_zipped

  def self.zip!(filepath, options={}, &blk)
    new(options.merge(filepath: filepath)).tap do |zip_utility|
      yield zip_utility if block_given?
      zip_utility.zip!
    end
  end

  def initialize(options={})
    @filepath = options[:filepath] || raise(ArgumentError, "Must supply :filepath for the zip file")
    @permissions = options[:permissions] || 0755
    @files_to_be_zipped = []
  end

  def add(filename, source_path)
    @files_to_be_zipped << [filename, source_path]
  end

  def zip!
    Zip::File.open(filepath, Zip::File::CREATE) do |zipfile|
      @files_to_be_zipped.each do |filename, source_path|
        zipfile.add(filename, source_path)
      end
    end
    File.chmod(@permissions, filepath)
    filepath
  end

end
