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

  attr_accessor :filter, :sample, :rows, :member, :from_update_date, :until_update_date, :from_pub_date, :until_pub_date, :file, :type

  def queue_work_import
    (0...total_results).step(1000) do |offset|
      options = {
        from_update_date: from_update_date,
        until_update_date: until_update_date,
        from_pub_date: from_pub_date,
        until_pub_date: until_pub_date,
        file: file,
        member: member,
        sample: sample,
        offset: offset }
      ImportJob.perform_later(self.class.to_s, options)
    end
  end

  def process_data(offset = 0)
    result = get_data(offset)
    result = parse_data(result)
    result = import_data(result)
    result.length
  end

  def import_data(items)
    Array(items).map do |item|
      work = Work.find_or_create(item)
      work ? work.id : nil
    end
  end
end
