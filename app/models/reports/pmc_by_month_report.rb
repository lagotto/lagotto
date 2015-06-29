class PmcByMonthReport
  include Reportable::ToCsv
  include Dateable

  class Query
    attr_reader :pmcr, :starting_year, :starting_month

    def initialize(pmcr, starting_year:, starting_month:)
      @pmcr = pmcr
      @starting_year = starting_year
      @starting_month = starting_month
    end

    def execute
      pmcr.months.joins(:work)
        .select("months.id, works.pid, CONCAT(months.year, '-', months.month) AS date_key, months.year, months.month, months.html, months.pdf, months.total")
        .where("(months.year >= :year AND months.month >= :month) OR (months.year > :year)", year: starting_year, month: starting_month)
        .group("works.pid")
        .order("works.id, year ASC, month ASC")
        .all
    end
  end

  def initialize(pmcr, format:, year:, month:)
    @format = format
    @dates = date_range(year:year, month:month)
    starting_year, starting_month = @dates.first[:year], @dates.first[:month]
    @query = Query.new(pmcr,
      starting_year: starting_year,
      starting_month: starting_month
    )
  end

  def headers
    ["pid_type", "pid"] + formatted_dates
  end

  def line_items
    @line_items ||= build_line_items
  end

  private

  def formatted_dates
    @formatted_dates ||= @dates.map { |date| "#{date[:year]}-#{date[:month]}" }
  end

  def results
    @results ||= @query.execute
  end

  def results_nested
    results_nested = Hash.new { |h,k| h[k] = {} }
    results.each do |result|
      results_nested[result][result.date_key] = value_for_result_and_format(result, @format)
    end
    results_nested
  end

  def build_line_items
    Array.new.tap do |line_items|
      results_nested.each_pair do |result, results_by_date_key|
        attributes = { pid_type: "doi", pid: result.pid }
        formatted_dates.each do |date_key|
          attributes[date_key] = results_by_date_key[date_key] ||= 0
        end
        line_items << Reportable::LineItem.new(attributes)
      end
    end
  end

  def value_for_result_and_format(result, format)
    return result.pdf + result.html if format == :combined
    return result.send(format) if result.respond_to?(format)
    raise NotImplementedError, "Don't know how to determine the value of a result for an unknown format: #{format.inspect}"
  end

end
