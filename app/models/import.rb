class Import
  # include HTTP request helpers
  include Networkable

  # include author methods
  include Authorable

  # include date helper methods
  include Dateable

  # include time helper methods
  include Measurable

  # include DOI helper methods
  include Resolvable

  attr_accessor :sample, :rows, :member, :from_update_date, :until_update_date, :from_pub_date, :until_pub_date, :file, :filepath, :type, :issn

  def initialize(options = {})
    @file = options.fetch(:file, nil)
    @filepath = options.fetch(:filepath, nil)
  end

  def queue_work_import
    (0...total_results).step(1000) do |offset|
      options = {
        from_update_date: from_update_date,
        until_update_date: until_update_date,
        from_pub_date: from_pub_date,
        until_pub_date: until_pub_date,
        file: file,
        filepath: filepath,
        member: member,
        sample: sample,
        offset: offset,
        type: type,
        issn: issn }
      Rails.logger.info "queue_work_import: #{options.inspect}"
      ImportJob.perform_later(self.class.to_s, options)
    end
  end

  def process_data(options)
    result = get_data(options)
    result = parse_data(result)
    result = import_data(result)
    result.length
  end

  def total_results
    content = File.open(filepath, 'r') { |f| f.read }
    JSON.parse(content).length
  rescue Errno::ENOENT, JSON::ParserError
    0
  end

  def get_data(options={})
    offset = options[:offset].to_i
    rows = (options[:rows] || 1000).to_i
    return [] if filepath.nil?

    content = File.open(filepath, 'r') { |f| f.read }
    json = JSON.parse(content)
    json[offset...offset + rows]
  end

  def import_data(items)
    Array(items).map do |item|
      work = Work.find_or_create(item)
      work ? work.id : nil
    end
  end
end
