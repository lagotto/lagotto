class MendeleyReport
  include Reportable::ToCsv

  class Query
    attr_reader :source_model

    def initialize(source_model)
      @source_model = source_model
    end

    def execute
      source_model.works.includes(:retrieval_statuses)
        .group("works.id")
        .select("works.pid, retrieval_statuses.readers, retrieval_statuses.total")
        .order("works.id ASC")
        .all
    end
  end

  def initialize(source_model)
    @query = Query.new(source_model)
  end

  def headers
    ["pid_type", "pid", "readers", "groups", "total"]
  end

  def line_items
    @line_items ||= results.map do |result|
      Reportable::LineItem.new(
        pid_type: "doi",
        pid: result.pid,
        readers: result.readers,
        groups: groups_value_for(result),
        total: result.total
      )
    end
  end

  private

  def groups_value_for(result)
    result.readers > 0 ? result.total - result.readers : 0
  end

  def results
    @results ||= @query.execute
  end

end
