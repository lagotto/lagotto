class SourceReport
  include Reportable::ToCsv

  class Query
    attr_reader :source_model

    def initialize(source_model)
      @source_model = source_model
    end

    def execute
      return [] unless source_model
      source_model.works.includes(:relations)
        .where("works.tracked = ?", 1)
        .group("works.id")
        .select("works.pid, relations.relation_type_id, relations.total")
        .all
        .order("works.published_on ASC")
    end
  end

  def initialize(source_model)
    @query = Query.new(source_model)
  end

  def headers
    ["pid", "html", "pdf", "total"]
  end

  def line_items
    @line_items ||= results.map do |result|
      build_line_item_for_result result
    end
  end

  def each_line_item(&blk)
    line_items.each(&blk)
  end

  protected

  def build_line_item_for_result(result)
    Reportable::LineItem.new(
      pid: result.pid,
      relation_type_id: result.relation_type_id,
      total: result.total
    )
  end

  private

  def results
    @results ||= @query.execute
  end
end
