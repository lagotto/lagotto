class SimpleSource < Source
    def get_query_url(work)
        total = config.total || 0
        # if this returns a hash it becomes the data returned from get_data
        return {
            data: {
                total: total
            }
        }.with_indifferent_access
    end

    def parse_data(result, work, options={})
        puts result
      total = result.deep_fetch('data', 'total') {35}
      { events: {
          source: name,
          work: work.pid,
          total: total,
          extra: [] } }
    end
  end
