class AlmCombinedStatsReport
  include Reportable::ToCsv

  def initialize(alm_report:, pmc_report:, counter_report:, mendeley_report:)
    @alm_report = alm_report
    @pmc_report = pmc_report
    @counter_report = counter_report
    @mendeley_report = mendeley_report
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

  def line_items
    Array.new.tap do |line_items|
      each_line_item_by_work_pid do |alm_line_item, pmc_line_item, counter_line_item, mendeley_line_item|
        if pmc_line_item
          pmc_html = pmc_line_item.field("html")
          pmc_pdf = pmc_line_item.field("pdf")
        end

        if counter_line_item
          counter_html = counter_line_item.field("html")
          counter_pdf = counter_line_item.field("pdf")
        end

        if mendeley_line_item
          mendeley_readers = mendeley_line_item.field("readers")
          mendeley_groups = mendeley_line_item.field("groups")
        end

        line_item = Reportable::LineItem.new(
          pmc_html:         (pmc_html         || 0),
          pmc_pdf:          (pmc_pdf          || 0),
          counter_html:     (counter_html     || 0),
          counter_pdf:      (counter_pdf      || 0),
          mendeley_readers: (mendeley_readers || 0),
          mendeley_groups:  (mendeley_groups  || 0)
        )

        @alm_report.headers.each do |header|
          line_item[header] = alm_line_item.field(header)
        end
        line_items << line_item
      end
    end
  end

  private

  def each_line_item_by_work_pid(&blk)
    @alm_report.line_items.each do |alm_line_item|
      work_pid = alm_line_item.field("pid")
      yield(
        alm_line_item,
        pmc_line_items_by_work_pid[work_pid],
        counter_line_items_by_work_pid[work_pid],
        mendeley_line_items_by_work_pid[work_pid]
      )
    end
  end

  def pmc_line_items_by_work_pid
    @pmc_line_items_by_work_pid ||= distinct_group_by_pid(@pmc_report.line_items)
  end

  def counter_line_items_by_work_pid
    @counter_line_items_by_work_pid ||= distinct_group_by_pid(@counter_report.line_items)
  end

  def mendeley_line_items_by_work_pid
    @mendeley_line_items_by_work_pid ||= distinct_group_by_pid(@mendeley_report.line_items)
  end

  def distinct_group_by_pid(array)
    array.reduce({}) do |hsh, item|
      key = item.field("pid")
      hsh[key] = item
      hsh
    end
  end
end
