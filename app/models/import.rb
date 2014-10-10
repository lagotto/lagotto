# encoding: UTF-8

class Import
  # include HTTP request helpers
  include Networkable

  TYPES_WITH_TITLE = %w(journal-article
                        proceedings-article
                        dissertation
                        standard
                        report
                        book
                        monograph
                        edited-book
                        reference-book
                        dataset)

  attr_accessor :filter, :sample, :rows, :member_list

  def initialize(options = {})
    from_update_date = options.fetch(:from_update_date, nil)
    until_update_date = options.fetch(:until_update_date, nil)
    from_pub_date = options.fetch(:from_pub_date, nil)
    until_pub_date = options.fetch(:until_pub_date, nil)
    type = options.fetch(:type, nil)
    member = options.fetch(:member, nil)
    issn = options.fetch(:issn, nil)
    sample = options.fetch(:sample, 0)

    @file = options.fetch(:file, nil)
    @sample = sample.to_i
    @member_list = member.to_s.split(",")

    unless @file
      from_update_date = Date.yesterday.to_s(:db) if from_update_date.blank?
      until_update_date= Date.yesterday.to_s(:db) if until_update_date.blank?
      until_pub_date= Date.today.to_s(:db) if until_pub_date.blank?

      @filter = "from-update-date:#{from_update_date}"
      @filter += ",until-update-date:#{until_update_date}"
      @filter += ",until-pub-date:#{until_pub_date}"
      @filter += ",from-pub-date:#{from_pub_date}" if from_pub_date
      @filter += ",type:#{type}" if type
      @filter += ",issn:#{issn}" if issn

      if @member_list.present?
        @filter += member_list.reduce("") do |sum, member|
          sum + ",member:#{member}"
        end
      end
    end
  end

  def total_results(options={})
    if @file
      @file.length
    else
      result = get_result(query_url(offset = 0, rows = 0), options)
      result.fetch('message', {}).fetch('total-results', 0)
    end
  end

  def queue_article_import
    if @sample > 0
      delay(priority: 2, queue: "article-import-queue").process_data
    else
      (0...total_results).step(1000) do |offset|
        delay(priority: 2, queue: "article-import").process_data(offset)
      end
    end
  end

  def process_data(offset = 0)
    result = get_data(offset)
    result = parse_data(result)
    result = import_data(result)
    result.length
  end

  def query_url(offset = 0, rows = 1000)
    url = "http://api.crossref.org/works?"
    if @sample > 0
      params = { filter: @filter, sample: @sample }
    else
      params = { filter: @filter, offset: offset, rows: rows }
    end
    url + params.to_query
  end

  def get_data(offset = 0, options={})
    if @file
      result = get_text(offset)
    else
      result = get_result(query_url(offset), options)
    end
  end

  def get_text(offset = 0, rows = 1000)
    text = @file.slice(offset...(offset + rows))
    items = text.map do |line|
      line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
      raw_uid, raw_published_on, raw_title = line.strip.split(" ", 3)

      uid = Article.from_uri(raw_uid.strip).values.first
      if raw_published_on
        # date_parts is an array of non-null integers: [year, month, day]
        # everything else should be nil and thrown away with compact
        date_parts = raw_published_on.split("-")
        date_parts = date_parts.map { |x| x.to_i > 0 ? x.to_i : nil }.compact
      else
        date_parts = []
      end
      title = raw_title ? raw_title.strip.chomp('.') : ""

      { Article.uid => uid,
        "issued" => { "date-parts" => [date_parts] },
        "title" => [title],
        "type" => "standard",
        "member" => member_list.first }
    end

    { "status" => "ok",
      "message" => { "items" => items } }
  end

  def parse_data(result)
    # return early if an error occured
    return [] unless result && result["status"] == "ok"

    items = result.fetch('message', {}).fetch('items', nil)
    Array(items).map do |item|
      uid = item.fetch("DOI", nil) || item.fetch(Article.uid, nil)
      date_parts = item["issued"]["date-parts"][0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      title = case item["title"].length
              when 0 then nil
              when 1 then item["title"][0]
              else item["title"][0].presence || item["title"][1]
              end

      if title.blank? && !TYPES_WITH_TITLE.include?(item["type"])
        title = item["container-title"][0].presence || "No title"
      end
      member = item.fetch("member", nil)
      member = member[30..-1].to_i if member

      { Article.uid_as_sym => uid,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: member }
    end
  end

  def import_data(items)
    Array(items).map do |item|
      article = Article.find_or_create(item)
      article ? article.id : nil
    end
  end
end
