class SimpleSource < Source
  @@total = 0
  # unusual usage:
  # instead of a url this method can return
  # a hash that represents the data
  def get_query_url(_)
    step ||= (config.step || 1)
    @@total = @@total + step
    hash = {data: {total: @@total}}
    return hash.with_indifferent_access
  end

  def parse_data(_, work, options={})
    { events: {
        source: name,
        work: work.pid,
        total: @@total,
        extra: [] } }
  end
end
