class CounterReport
  include Reportable::ToCsv

  class Query
    attr_reader :counter

    def initialize(counter)
      @counter = counter
    end

    def execute
      counter.works.includes(:retrieval_statuses)
        .group("works.id")
        .select("works.pid, retrieval_statuses.html, retrieval_statuses.pdf, retrieval_statuses.total")
        .all
        .order("works.id ASC")
    end
  end

  def initialize(counter)
    @query = Query.new(counter)
  end

  def headers
    ["pid_type", "pid", "html", "pdf", "total"]
  end

  def line_items
    @line_items ||= results.map do |result|
      Reportable::LineItem.new(
        pid_type: "doi",
        pid: result.pid,
        html: result.html,
        pdf: result.pdf,
        total: result.total
      )
    end
  end

  private

  def results
    @results ||= @query.execute
  end

end
