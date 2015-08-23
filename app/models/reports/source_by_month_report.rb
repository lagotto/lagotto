class SourceByMonthReport
  include Reportable::ToCsv
  include Dateable

  class Query
    attr_reader :source_model, :starting_year, :starting_month

    def initialize(source_model, options={})
      @source_model = source_model
      @starting_year = options[:starting_year] || raise(ArgumentError, "Must supply :starting_year")
      @starting_month = options[:starting_month] || raise(ArgumentError, "Must supply :starting_month")
    end

    def execute
      source_model.months.joins(:work)
        .select("months.id, works.pid, CONCAT(months.year, '-', months.month) AS date_key, months.year, months.month, months.html, months.pdf, months.total")
        .where("(months.year >= :year AND months.month >= :month) OR (months.year > :year)", year: starting_year, month: starting_month)
        .group("works.pid")
        .order("works.published_on, year ASC, month ASC")
        .all
    end
  end

  def self.value_provider_block_registrar
    @value_provider_block_registrar ||= begin
      parent_class = ancestors[1]
      if parent_class.respond_to?(:value_provider_block_registrar)
        parent_class.value_provider_block_registrar.dup
      else
        BlockRegistrar.new
      end
    end
  end

  def self.register_value_provider_for_format(format, &blk)
    raise ArgumentError, "Must supply a block!" unless blk
    value_provider_block_registrar[format] = blk
  end

  def self.register_default_value_provider(&blk)
    raise ArgumentError, "Must supply a block!" unless blk
    value_provider_block_registrar.default_block = blk
  end

  register_value_provider_for_format(:combined) do |result|
    result.pdf + result.html
  end

  register_default_value_provider do |result, format|
    result.send(format)
  end

  def initialize(source_model, options={})
    @format = options[:format] || raise(ArgumentError, "Must supply :format")
    year =options[:year] || raise(ArgumentError, "Must supply :year")
    month =options[:month] || raise(ArgumentError, "Must supply :month")
    @dates = date_range(year: year, month: month)
    starting_year, starting_month = @dates.first[:year], @dates.first[:month]
    @query = Query.new(source_model,
      starting_year: starting_year,
      starting_month: starting_month
    )
  end

  def headers
    ["pid"] + formatted_dates
  end

  def each_line_item(&blk)
    line_items.each(&blk)
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
      value_provider = self.class.value_provider_block_registrar[@format]
      results_nested[result][result.date_key] = value_provider.call(result, @format)
    end
    results_nested
  end

  def build_line_items
    Array.new.tap do |line_items|
      results_nested.each_pair do |result, results_by_date_key|
        attributes = { pid: result.pid }
        formatted_dates.each do |date_key|
          attributes[date_key] = results_by_date_key[date_key] ||= 0
        end
        line_items << Reportable::LineItem.new(attributes)
      end
    end
  end

end
