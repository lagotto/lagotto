class PlosImport < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    date_range = "publication_date:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "*:*",
               start: offset,
               rows: rows,
               fl: "id,publication_date,title_display,cross_published_journal_name,author_display,volume,issue,elocation_id",
               fq: "#{date_range}+doc_type:full",
               wt: "json" }
    url + params.to_query
  end

  def get_relations_with_related_works(items)
    Array(items).map do |item|
      date_parts = get_date_parts(timestamp)
      doi = item.fetch("id", nil)

      subj = { "pid" => doi_as_url(doi),
               "author" => get_authors(item.fetch("author_display", [])),
               "container-title" => item.fetch("cross_published_journal_name", []).first,
               "title" => item.fetch("title_display", nil),
               "issued" => get_iso8601_from_time(item.fetch("publication_date", nil)),
               "DOI" => doi,
               "publisher_id" => publisher_id,
               "volume" => item.fetch("volume", nil),
               "issue" => item.fetch("issue", nil),
               "page" => item.fetch("elocation_id", nil),
               "tracked" => tracked,
               "type" => "article-journal" }

      { prefix: "10.1371",
        relation: { "subj_id" => subj["pid"],
                    "source_id" => source_id,
                    "publisher_id" => subj["publisher_id"] },
        subj: subj }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://api.plos.org/search?"
  end

  # publisher_id is PLOS CrossRef member id
  def publisher_id
    340
  end

  def cron_line
    config.cron_line || "20 11,16 * * 1-5"
  end
end
