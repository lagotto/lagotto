class SourceReport
  include Reportable::ToCsv

  class Query
    attr_reader :source_model

    def initialize(source_model)
      @source_model = source_model
    end

    def execute
      source_model.works.includes(:retrieval_statuses)
        .group("works.id")
        .select("works.pid, retrieval_statuses.html, retrieval_statuses.pdf, retrieval_statuses.total")
        .all
        .order("works.id ASC")
    end
  end

  def initialize(source_model)
    @query = Query.new(source_model)
  end

  def headers
    ["pid_type", "pid", "html", "pdf", "total"]
  end

  def line_items
    @line_items ||= results.map do |result|
      build_line_item_for_result result
    end
  end

  protected

  def build_line_item_for_result(result)
    Reportable::LineItem.new(
      pid_type: "doi",
      pid: result.pid,
      html: result.html,
      pdf: result.pdf,
      total: result.total
    )
  end

  private

  def results
    @results ||= @query.execute
  end

end
