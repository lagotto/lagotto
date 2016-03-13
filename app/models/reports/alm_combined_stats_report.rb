class AlmCombinedStatsReport
  include Reportable::ToCsv

  def initialize(options={})
    @alm_report = options[:alm_report] || raise(ArgumentError, "Must supply :alm_report")
    @pmc_report = options[:pmc_report] || raise(ArgumentError, "Must supply :pmc_report")
    @counter_report = options[:counter_report] || raise(ArgumentError, "Must supply :counter_report")
    @mendeley_report = options[:mendeley_report] || raise(ArgumentError, "Must supply :mendeley_report")
  end

  def headers
    @alm_report.headers + [
      "mendeley_readers",
      "mendeley_groups",
      "pmc_html",
      "pmc_pdf",
      "counter_html",
      "counter_pdf"
    ]
  end

  def each_line_item(&blk)
    line_items.each(&blk)
  end

  def line_items
    @line_items ||= begin
      line_items_by_pid = Hash.new do |h,k|
        defaults = {
          pmc_html: 0,
          pmc_pdf: 0,
          counter_html: 0,
          counter_pdf: 0,
          mendeley_readers: 0,
          mendeley_groups: 0
        }

        h[k] = Reportable::LineItem.new(**defaults)
      end

      populate_with_alm line_items_by_pid
      populate_with_pmc line_items_by_pid
      populate_with_counter line_items_by_pid
      populate_with_mendeley line_items_by_pid

      line_items_by_pid.values
    end
  end

  private

  def populate_with_alm(line_items_by_pid)
    alm_headers = @alm_report.headers
    @alm_report.each_line_item do |alm_line_item|
      line_item = line_items_by_pid[alm_line_item.field("pid")]
      alm_headers.each do |header|
        line_item[header] = alm_line_item.field(header)
      end
    end
  end

  def populate_with_pmc(line_items_by_pid)
    @pmc_report.each_line_item do |pmc_line_item|
      line_item = line_items_by_pid[pmc_line_item.field("pid")]
      line_item[:pmc_html] = pmc_line_item.field("total")
      #line_item[:pmc_pdf] = pmc_line_item.field("total")
    end
  end

  def populate_with_counter(line_items_by_pid)
    @counter_report.each_line_item do |counter_line_item|
      line_item = line_items_by_pid[counter_line_item.field("pid")]
      line_item[:counter_html] = counter_line_item.field("total")
      #line_item[:counter_pdf] = counter_line_item.field("total")
    end
  end

  def populate_with_mendeley(line_items_by_pid)
    @mendeley_report.each_line_item do |mendeley_line_item|
      line_item = line_items_by_pid[mendeley_line_item.field("pid")]
      line_item[:mendeley_readers] = mendeley_line_item.field("total")
      #line_item[:mendeley_groups] = mendeley_line_item.field("total")
    end
  end
end
