class AlmStatsReport
  include Reportable::ToCsv

  class Query
    attr_reader :source_models

    def initialize(source_models)
      @source_models = source_models
    end

    def execute
      select_clause =  "works.pid, works.published_on, works.title"
      source_models.each do |source|
        select_clause += ", MAX(CASE WHEN rs.source_id = #{source.id} THEN rs.total END) AS #{source.name}"
      end

      Work.select(select_clause)
        .where("works.tracked = ?", 1)
        .joins("LEFT JOIN retrieval_statuses rs ON works.id = rs.work_id")
        .group("works.id")
        .order("works.published_on ASC")
        .all
    end
  end

  attr_reader :sources

  def initialize(sources)
    @sources = sources
    @query = Query.new(sources)
  end

  def headers
    ["pid", "publication_date", "title"] + sources.map(&:name)
  end

  def each_line_item(&blk)
    line_items.each(&blk)
  end

  def line_items
    @line_items ||= results.map do |result|
      build_line_item_for_result(result)
    end
  end

  private

  def build_line_item_for_result(result)
    attrs = {
      pid: result.pid,
      publication_date: result.published_on,
      title: result.title
    }
    Reportable::LineItem.new(attrs).tap do |line_item|
      sources.each do |source|
        line_item[source.name] = result.send(source.name) || 0
      end
    end
  end

  def results
    @results ||= @query.execute
  end
end
