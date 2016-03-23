class MendeleyReport
  include Reportable::ToCsv

  class Query
    attr_reader :source_model

    def initialize(source_model)
      @source_model = source_model
    end

    def execute
      return [] unless source_model
      source_model.works.includes(:aggregations)
        .group("works.id")
        .select("works.pid, aggregations.relation_type_id, aggregations.total")
        .order("works.published_on ASC")
        .all
    end
  end

  def initialize(source_model)
    @query = Query.new(source_model)
  end

  def headers
    ["pid", "readers", "groups", "total"]
  end

  def line_items
    @line_items ||= results.map do |result|
      Reportable::LineItem.new(
        pid: result.pid,
        relation_type_id: result.relation_type_id,
        total: result.total
      )
    end
  end

  def each_line_item(&blk)
    line_items.each(&blk)
  end

  private

  def results
    @results ||= @query.execute
  end

end
