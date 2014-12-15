class Import
  # include HTTP request helpers
  include Networkable

  # include author methods
  include Authorable

  # include DOI helper methods
  include Resolvable

  attr_accessor :filter, :sample, :rows, :member_list

  def queue_work_import
    if @sample && @sample > 0
      delay(priority: 2, queue: "work-import-queue").process_data
    else
      (0...total_results).step(1000) do |offset|
        delay(priority: 2, queue: "work-import").process_data(offset)
      end
    end
  end

  def process_data(offset = 0)
    result = get_data(offset)
    result = parse_data(result)
    result = import_data(result)
    result.length
  end

  def get_data(offset = 0, options={})
    result = get_result(query_url(offset), options)
  end

  def import_data(items)
    Array(items).map do |item|
      work = Work.find_or_create(item)
      work ? work.id : nil
    end
  end
end
